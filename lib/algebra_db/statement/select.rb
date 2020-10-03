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

        relation = relationish.to_relation(:"tbl_#{@froms.length + 1}")
        @froms << relation.from_clause
        relation
      end

      def where(filter)
        @wheres << filter
      end

      def select(*selects)
        @select = Build::SelectList.new(*selects)
      end

      def render_syntax(builder)
        raise ArgumentError, 'no select' unless @select

        builder.text('SELECT')
        @select.render_syntax(builder)
        builder.text('FROM')
        builder.separate(@froms) { |f, b| f.render_syntax(b) }
        return if @wheres.empty?

        builder.text('WHERE')
        builder.separate(@wheres, separator: ' AND') { |w, b| w.render_syntax(b) }
      end
    end
  end
end
