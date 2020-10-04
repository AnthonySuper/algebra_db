module AlgebraDB
  module Statement
    ##
    # A select statement executor.
    class Select
      def self.run_syntax(&block)
        new.tap { |t| t.instance_eval(&block) }
      end

      def initialize
        @wheres = []
        @froms = []
        @joins = []
        @select = nil
      end

      ##
      # Give a {AlgebgraDB::Table} or something else
      # that responds to #to_relation, gives you back
      # a relation that you can use further in the query.
      #
      # If you use `relationish` in another query (by storing it in a variable out of scope),
      # it will break!
      def all(relationish)
        unless relationish.respond_to?(:to_relation)
          raise ArgumentError, "#{relationish} does not respond to to_relation!"
        end

        relation = relationish.to_relation(next_table_alias)
        @froms << relation.from_clause
        relation
      end

      def where(filter)
        @wheres << filter
      end

      def select(*selects)
        @select = Build::SelectList.new(*selects)
      end

      def join_relationship(relationship, type: :inner)
        joins(relationship.joined_table, type: type) do |rel|
          relationship.join_clause(rel)
        end
      end

      def joins(other_table, type: :inner, &block)
        relation = other_table.to_relation(next_table_alias)
        join_clause = block.call(relation)
        @joins << Build::Join.new(type, relation.from_clause, join_clause)
        relation
      end

      def raw_param(ruby_value)
        Build.param(ruby_value)
      end

      def to_delivery
        raise ArgumentError, 'nothing selected' unless @select

        Exec::Delivery.new(self, @select.row_decoder)
      end

      def render_syntax(builder)
        raise ArgumentError, 'no select' unless @select

        builder.text('SELECT')
        @select.render_syntax(builder)
        builder.text('FROM')
        builder.separate(@froms) { |f, b| f.render_syntax(b) }
        @joins.each { |j| j.render_syntax(builder) }
        return if @wheres.empty?

        builder.text('WHERE')
        builder.separate(@wheres, separator: ' AND') { |w, b| w.render_syntax(b) }
      end

      def next_table_alias
        :"t_#{@froms.count + @joins.count + 1}"
      end
    end
  end
end
