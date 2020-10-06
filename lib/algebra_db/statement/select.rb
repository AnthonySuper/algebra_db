module AlgebraDB
  module Statement
    ##
    # A select statement.
    # Supports filtering, joining, and doing all sorts of other cool things.
    #
    # You can use +#to_delivery+ on this to get an
    # +AlgebraDB::Exec::Delivery+, suitable for executing with a connection.
    class Select
      ##
      # Run a syntax block in the context of a new select statement.
      # This is *almost always* what you want as select statements are *intentionally* mutable.
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
      # Give a {AlgebraDB::Table} or something else
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

      ##
      # Add a new filtering clause to this select statement.
      # Should be an instance of +AlgebraDB::Value::Bool+,
      # probably obtained with expression manipulation.
      def where(filter)
        @wheres << filter
      end

      ##
      # Specify a subset of columns you'd like to select.
      # You can use a hash here to rename columns from their default.
      # If ther is no default name, you *must* pass them in the context of a hash.
      #
      # @example Column Selects
      #   select(users.id, users.name)
      # @example Column Selects with Alias
      #   select(users.id, alternative_name: users.name)
      # @example Operator Selects
      #   select(full_name: users.first_name.append(raw_param(' ')).append(raw_param(' '))
      def select(*selects)
        @select = Build::SelectList.new(*selects)
      end

      ##
      # Given an +AlgebraDB::Def::Relationship+, join in the related table.
      def join_relationship(relationship, type: :inner)
        joins(relationship.joined_table, type: type) do |rel|
          relationship.join_clause(rel)
        end
      end

      ##
      # Join in another table.
      # We will call the given block to obtain the join condition.
      #
      # @example Basic Join
      #   joins(User) { |u| u.id.eq(user_audits.user_id) }
      # @example More Complex Join
      #   joins(User) do |other_users|
      #     other_users.id.neq(users.id).and(other_users.availability.overlaps(users.availability)
      #   end
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
