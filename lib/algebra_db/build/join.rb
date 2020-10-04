module AlgebraDB
  module Build
    ##
    # Syntax for a join.
    class Join < Struct.new(:type, :table, :condition) # rubocop:disable Style/StructInheritance
      JOIN_EXPRS = {
        inner: 'INNER JOIN',
        left: 'LEFT OUTER JOIN',
        right: 'RIGHT OUTER JOIN',
        inner_lateral: 'INNER JOIN LATERAL',
        left_lateral: 'LEFT JOIN LATERAL',
        right_lateral: 'RIGHT JOIN LATERAL'
      }.freeze

      TYPES = JOIN_EXPRS.keys.freeze

      def initialize(type, table, condition)
        super(type, table, condition)

        raise ArgumentError, "unrecognized join type #{type}" unless TYPES.include?(type)
      end

      def render_syntax(builder)
        builder.text(join_expr)
        table.render_syntax(builder)
        builder.text('ON')
        condition.render_syntax(builder)
      end

      def join_expr
        JOIN_EXPRS[type]
      end
    end
  end
end
