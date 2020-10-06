module AlgebraDB
  module Statement
    ##
    # Models an insert statement.
    class Insert
      def self.run_syntax(&block)
        new.tap { |t| t.instance_eval(&block) }
      end

      ##
      # Gets you an #insert statement that will
      # insert all of hashes into the table, and return
      # all of that table's columns.
      #
      # Will throw a nasty error if the hashess don't have consistent keys.
      # Can handle passing a single hash h, equivalent to passing [h]
      def self.insert_hash(table, hashes)
        hashes = [hashes] unless hashes.is_a?(Array)
        keys = hashes.first.keys
        run_syntax do
          into(table, keys.map(&:to_sym))
          hashes.each do |h|
            value(*keys.map { |k| param(h.fetch(k)) })
          end
          returning(*table.column_names)
        end
      end

      def initialize
        @into = nil
        @values = []
        @returning = nil
      end

      def returns_values?
        !@returning.nil?
      end

      def into(table, *columns)
        @into_table = table
        @into = table.into_clause(columns.flatten)
      end

      def value(*value_items)
        @values << Build::InsertValue.new(value_items.flatten)
      end

      def returning(*columns)
        raise ArgumentError, 'use #into first so we can check column names!' unless @into_table
        raise ArgumentError, 'returning specified twice?' if @returning

        self_aliased = @into_table.new(@into_table.table_name)

        cols = columns.flatten.map do |c|
          raise ArgumentError, "unknown column #{c}" unless @into_table.column?(c.to_sym)

          self_aliased.column(c.to_sym)
        end

        @returning = Build::SelectList.new(cols)
      end

      def to_delivery
        Exec::Delivery.new(self, @returning&.row_decoder)
      end

      def render_syntax(builder)
        builder.text('INSERT INTO')
        @into.render_syntax(builder)

        if @values.any?
          builder.text('VALUES')
          builder.separate(@values) { |v, b| v.render_syntax(b) }
        end

        return unless @returning

        builder.text('RETURNING')
        @returning.render_syntax(builder)
      end

      ##
      # Inside an insert you can use `param` to parameterize something.
      def param(val)
        Build.param(val)
      end
    end
  end
end
