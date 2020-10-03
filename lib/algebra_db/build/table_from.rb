module AlgebraDB
  module Build
    TableFrom = Struct.new(:original_table, :table_alias) do
      def render_syntax(builder)
        builder.text(original_table.to_s)
        builder.text(table_alias.to_s)
      end
    end
  end
end
