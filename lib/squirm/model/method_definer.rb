require "date"

module Squirm
  module Model
    class MethodDefiner
      def initialize(model_class)
        @model_class = model_class
      end

      def define_getter(attribute, code)
        @model_class.class_eval(<<-EOD, __FILE__, __LINE__ + 1)
          def #{attribute}
            if defined? @#{attribute}
              @#{attribute}
            else
              return unless @__attributes.key?("#{attribute}")
              #{code % attribute}
            end
          end
        EOD
      end

      def define_setter(attribute)
        @model_class.class_eval(<<-EOD, __FILE__, __LINE__ + 1)
          def #{attribute}=(value)
            @#{attribute} = value
          end
        EOD
      end

      def method_missing(sym, *args)
        attribute = sym.to_s.tr("=", "")
        value     = args.first
        base      = '@__attributes["%s"]'
        cast = begin
          case value
          when Float      then base + '.to_f'
          when Rational   then base + '.to_r'
          when Complex    then base + '.to_c'
          when Symbol     then base + '.to_sym'
          when Numeric    then base + '.to_i'
          when TrueClass  then base + ' == "t"'
          when FalseClass then base + ' == "t"'
          when DateTime   then "DateTime.parse(#{base})"
          when Date       then "Date.parse(#{base})"
          else base + ".to_s"
          end
        end
        define_getter(attribute, cast)
        define_setter(attribute) unless value.frozen?
      end
    end
  end
end