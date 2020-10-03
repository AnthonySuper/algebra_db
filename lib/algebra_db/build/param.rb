module AlgebraDB
  module Build
    Param = Struct.new(:value) do
      def render_syntax(builder)
        builder.param(value)
      end
    end
  end
end
