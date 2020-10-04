module AlgebraDB
  module Build
    SelectItem = Struct.new(:value, :select_alias) do
      def initialize(value, select_alias)
        super(value, select_alias)

        raise ArgumentError, "value can't be nil" if value.nil?
        raise ArgumentError, "select_alias can't be nil" if select_alias.nil?
      end

      def render_syntax(builder)
        value.render_syntax(builder)
        builder.text 'AS'
        builder.text(%("#{select_alias}"))
      end

      def decoder
        value.decoder
      end
    end
  end
end
