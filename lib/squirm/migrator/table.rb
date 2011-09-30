module Squirm

  module Migrator

    class Table

      attr :columns, :name

      def initialize(name)
        @name    = name
        @columns = []
      end

      def quoted_name
        Squirm.quote_ident name
      end

      def add_column(*names)
        names.each do |name|
          column = Column.new(name)
          column.templates.map {|t| t.table = self}
          @columns << column
        end
        self
      end

      def api
        templates = ["schema", "api/get", "api/create", "api/update", "api/delete"]
        templates.map do |template|
          erb = File.read File.expand_path("../templates/sql/#{template}.sql.erb", __FILE__)
          Template.new erb, :table => self
        end
      end

      def template
        erb = File.read File.expand_path("../templates/sql/table.sql.erb", __FILE__)
        Template.new erb, :table => self, :column_padding => column_padding
      end

      private

      def column_padding
        columns.inject(0) do |longest, col|
          col.name.length > longest ? col.name.length : longest
        end + 3
      end
    end
  end
end