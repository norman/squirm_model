require "active_model"
require "squirm/model/sample"
require "squirm/model/method_definer"
require "squirm/migrator"

module Squirm

  module Model

    include ActiveModel::Naming

    # Raised when an instance could not be found.
    class NotFound < StandardError
    end

    attr :api
    attr :__attributes

    def self.extended(base)
      base.class_eval do
        include ActiveModel::Conversion
        include InstanceMethods
      end
    end

    # Invoke {#finalize} on all Squirm models.
    def self.finalize
      ObjectSpace.each_object(self) do |mod|
        mod.finalize
      end
    end

    # Invoke to load API. This allows classes to be set up before the API
    # has been created, or the db connection established.
    def finalize
      return if defined? @api
      sql = Pathname(__FILE__).dirname.join("model/schema_functions.sql").read
      schema_name = model_name.to_s.downcase
      Squirm.exec(sql, [schema_name]) do |result|
        @api = OpenStruct.new Hash[result.map do |row| [
          row["name"].to_sym,
          Procedure.new(row["name"], :schema => schema_name).load
        ]
        end]
      end
    end

    def sample(arg = nil, &block)
      if block_given?
        @sample_block = block
        yield MethodDefiner.new(self)
      elsif !arg
        @sample ||= begin
          @sample = Sample.new
          @sample_block.call(@sample)
          @sample
        end
      else
        sample = Sample.new
        @sample_block.call(sample)
        sample.each do |key, value|
          setter = :"#{key}="
          arg.send(setter, value) if arg.respond_to?(setter)
        end
        return arg
      end
    end

    def exec(query, &block)
      Squirm.exec query do |result|
        result.map do |hash|
          instance = allocate
          instance.instance_variable_set :@__attributes, hash
          yield instance if block_given?
          instance
        end
      end
    end

    def to_ddl
      buffer = []
      table = Squirm::Migrator::Table.new(name.downcase)
      table.add_column(*sample.keys)
      buffer << table.template.render
      table.api.each {|template| buffer << template.render}
      buffer.map(&:strip).join("\n\n")
    end

    def create(*args)
      get api.create[*args]
    end

    def get(id)
      api.get.call(id) do |result|
        raise NotFound if result.ntuples == 0
        hash = result.first
        instance = allocate
        instance.instance_variable_set :@__attributes, hash
        instance
      end
    end

    def delete(id)
      api.delete[id]
    end

    module InstanceMethods

      def initialize(options = {})
        @__attributes = options
      end

      def update(params)
        procedure = self.class.api.update
        procedure.call to_hash.merge params
      end

      def to_hash
        Hash[self.class.sample.keys.map {|key| [key, send(key)]}]
      end

      def save
        if persisted?
          update to_hash
        else
          @id = self.class.api.create[to_hash]
          reload
        end
      end

      def persisted?
        !! self.id
      end

      def reload
        self.class.api.get.call(id) do |result|
          @__attributes = result.first
          @__attributes.keys.each do |key|
            remove_instance_variable :"@#{key}"
          end
        end
      end
    end
  end
end
