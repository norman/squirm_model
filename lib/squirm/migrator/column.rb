module Squirm
  module Migrator
    class Column

      class Type
        extend Ambry::Model
        use :squirm
        field :name, :definition, :patterns, :priority, :templates, :findable,
          :creatable, :updatable, :sql

        undef :templates
        def templates
          @attributes[:templates] or []
        end

        filters do
          def by_priority
            sort {|a, b| b.priority <=> a.priority}
          end
        end

        def =~(string)
          patterns.any? {|pattern| string.match pattern}
        end

      end

      attr :name

      def initialize(name)
        @name = name
      end

      def quoted_name
        Squirm.quote_ident name
      end

      def type
        @type ||= Type.by_priority.first {|type| type =~ name}
      end

      def definition
        type.definition
      end

      def to_sql
        "#{quoted_name} #{definition}"
      end

      def templates
        @templates ||= begin
          @templates = type.templates.map do |template|
            Template.from_path "#{template}.sql.erb", :column => self
          end
        end
      end
    end
  end
end
