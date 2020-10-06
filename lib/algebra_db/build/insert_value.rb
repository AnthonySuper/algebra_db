module AlgebraDB
  module Build
    ##
    # Models one value tuple from an insert list.
    class InsertValue < Struct.new(:sql_values) # rubocop:disable Style/StructInheritance
      def initialize(sql_values)
        super(sql_values)

        sql_values.each do |v|
          unless v.respond_to?(:render_syntax)
            raise ArgumentError, "#{v} does not respond to to_syntax (wrap in a param)"
          end
        end
      end

      def render_syntax(builder)
        builder.parenthesize do
          builder.separate(sql_values) do |v, b|
            v.render_syntax(b)
          end
        end
      end
    end
  end
end
