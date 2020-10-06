module AlgebraDB
  module Build
    Into = Struct.new(:table_name, :columns) do
      def render_syntax(builder)
        builder.text_nospace(table_name.to_s)
        builder.parenthesize do
          builder.separate(columns) do |c, b|
            b.text(c.to_s)
          end
        end
      end
    end
  end
end
