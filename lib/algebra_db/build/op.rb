module AlgebraDB
  module Build
    Op = Struct.new(:operator, :lhs, :rhs) do
      def render_syntax(builder)
        builder.parenthesize do
          lhs.render_syntax(builder)
          builder.text(operator.to_s)
          rhs.render_syntax(builder)
        end
      end
    end
  end
end
