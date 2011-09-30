require "erb"
require "pathname"

module Squirm
  
  module Migrator

    # A class to easily create a binding for an Erb template, because I don't like
    # the def_class and def_method methods that ship with Erb. Not using an
    # OpenStruct either because it uses an internal @table variable that makes it
    # hard to deal with when our main template has a variable named "table."
    class Template
      attr :__template__

      def initialize(template, hash = {})
        hash.each {|key, value| self[key] = value}
        @__template__ = template
      end

      def self.from_path(path, hash = {})
        unless Pathname.new(path).absolute?
          path = File.expand_path(File.join("..", "templates", path), __FILE__)
        end
        new File.read(path), hash
      end

      def render(&block)
        ERB.new(__template__, nil, '-%>').result(binding)
      end

      private

      def method_missing(sym, *args, &block)
        sym =~ /=\z/ ? self[sym.to_s.gsub(/=\z/, '')] = args.first : self[sym]
      end

      def []=(key, value)
        instance_variable_set :"@#{key}", value
      end

      def [](key)
        instance_variable_get :"@#{key}"
      end
    end
  end
end