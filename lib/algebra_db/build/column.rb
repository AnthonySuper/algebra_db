module AlgebraDB
  module Build
    Column = Struct.new(:table, :column) do
      def render_syntax(builder)
        builder.text(%("#{table}"."#{column}"))
      end

      def to_select_item
        SelectItem.new(self, column)
      end
    end
  end
end
