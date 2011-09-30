require "ostruct"
require "forwardable"

module Squirm
  module Model
    class Sample < OpenStruct
      extend Forwardable
      include Enumerable
      def_delegators :@table, :each, :keys, :[], :[]=, :to_hash
    end
  end
end
