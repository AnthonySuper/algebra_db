module AlgebraDB
  module Build
    ##
    # Build up a select list.
    class SelectList < Struct.new(:items) # rubocop:disable Style/StructInheritance
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

      ##
      # Row decoder that delegates to the decoders of
      # the items in the select list.
      class RowDecoder < AlgebraDB::Exec::RowDecoder
        def initialize(columns) # rubocop:disable Lint/MissingSuper
          @columns = columns
          @column_decoders = columns.map(&:decoder)
        end

        attr_reader :column_decoders

        def pg_type_map
          PG::TypeMapByColumn.new(column_decoders.map(&:pg_decoder))
        end

        def decode_row(row)
          values = row.values.map.with_index do |r, i|
            @column_decoders[i].decode_value(r)
          end
          row_struct.new(*values)
        end

        def row_struct
          @row_struct ||= Struct.new(*@columns.map { |c| c.select_alias.to_sym })
        end
      end

      def row_decoder
        RowDecoder.new(items)
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
