module AlgebraDB
  module Build
    SelectItem = Struct.new(:value, :select_alias) do
      def render_syntax(builder)
        value.render_syntax(builder)
        builder.text 'AS'
        builder.text(%("#{select_alias}"))
      end
    end
  end
end
