module AlgebraDB
  module Build
    Op = Struct.new(:operator, :lhs, :rhs) do
      def render_syntax(builder)
        lhs.render_syntax(builder)
        builder.text(operator)
        rhs.render_syntax(builder)
      end
    end
  end
end
