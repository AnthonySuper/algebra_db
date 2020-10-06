module AlgebraDB
  module Statement
    ##
    # Modules an UPDATE statement.
    class Update
      def self.run_syntax(&block)
        new.tap { |t| t.instance_eval(&block) }
      end

      def initialize
        @sets = []
        @wheres = []
      end

      ##
      # Returns a relation that you can use.
      def table(table)
        @table = table

        @aliased_table = @table.new(@table.table_name)
      end

      def set(column, value)
        raise ArgumentError, "don't know what table we're updating!" unless @table
        raise ArgumentError, "#{column} is not a column" unless @table.column?(column.to_sym)

        @sets << Build::Set.new(column, value)
      end

      def param(parameter)
        Build.param(parameter)
      end

      def where(cond)
        @wheres << cond
      end

      def returning(*columns)
        raise ArgumentError, 'need to know what table first!' unless @table

        columns = columns.flatten.map do |c|
          if c.is_a?(Symbol)
            @aliased_table.column(c.to_sym)
          else
            c
          end
        end

        @returning = Build::SelectList.new(columns)
      end

      def to_delivery
        Exec::Delivery.new(self, @returning&.row_decoder)
      end

      def render_syntax(builder)
        builder.text('UPDATE')
        builder.text(@table.table_name.to_s)
        builder.text('SET')
        builder.separate(@sets) { |s, b| s.render_syntax(b) }

        render_wheres(builder)
        render_returning(builder)
      end

      private

      def render_wheres(builder)
        return unless @wheres.any?

        builder.text('WHERE')
        builder.separate(@wheres, separator: ' AND') { |w, b| w.render_syntax(b) }
      end

      def render_returning(builder)
        return unless @returning

        builder.text('RETURNING')

        @returning.render_syntax(builder)
      end
    end
  end
end
