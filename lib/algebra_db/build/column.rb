module AlgebraDB
  module Build
    Column = Struct.new(:table, :column) do
      def render_syntax(builder)
        builder.text(%("#{table}"."#{column}"))
      end

      def default_select_item_alias
        column
      end
    end
  end
end
