module AlgebraDB
  module Build
    Set = Struct.new(:column_name, :value) do
      def initialize(column_name, value)
        super(column_name, value)

        return unless value.respond_to?(:to_syntax)

        raise ArgumentError, "#{value} is not a thing I can render to syntax (wrap in a param?)"
      end

      def render_syntax(builder)
        builder.text(column_name.to_s)
        builder.text('=')
        value.render_syntax(builder)
      end
    end
  end
end
