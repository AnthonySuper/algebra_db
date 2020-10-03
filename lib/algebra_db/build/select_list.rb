module AlgebraDB
  module Build
    SelectList = Struct.new(:items) do
      def initialize(*selects)
        super(selects.flat_map { |i| convert_select_item(i) })

        items.each do |i|
          same_name = items.select { |i2| i2.select_alias == i.select_alias }

          raise ArgumentError, "duplicate key #{i.select_alias}" if same_name.count > 1
        end
      end

      def render_syntax(builder)
        builder.separate(items) do |i, b|
          i.render_syntax(b)
        end
      end

      private

      def convert_select_item(item)
        if item.respond_to?(:to_select_item)
          item.to_select_item
        else
          item.map { |k, v| SelectItem.new(v, k) }
        end
      end
    end
  end
end
