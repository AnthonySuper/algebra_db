module AlgebraDB
  ##
  # Represent a table in AlgebraDB.
  # You should subclass this for your own tables.
  #
  # You should not call #new on this directly.
  # Instead, use the *class* in a syntax runner.
  class Table
    class << self
      ##
      # Hash of column_name -> column_type
      #
      # This returns a value modified with {#dup}, so modifying it
      # will have no effect on the table defintion.
      def columns
        (@columns || {}).dup
      end

      ##
      # We customize the inspect method to return a quick defintion of this table.
      # This makes working with it in a REPL much, much easier.
      def inspect
        str = "#<#{name}:#{object_id} "
        str << "columns=[#{columns.keys.map(&:inspect).join(', ')}]>"
      end

      def column(name, value)
        value = ::AlgebraDB::Value.const_get(value) if value.is_a?(Symbol)
        @columns ||= {}
        @columns[name.to_sym] = value
        define_method(name) do
          value.new(Build::Column.new(table_alias, name))
        end
      end

      ##
      # Does this table contain this column?
      def column?(name)
        columns.key?(name.to_sym)
      end

      def to_relation(relation_alias)
        new(relation_alias)
      end

      def relationship(name, other_table, &block)
        (@relationships ||= {})[name] = other_table
        define_method(name) do
          relater_proc =
            if block.arity == 2
              proc { |other_relation| block.call(self, other_relation) }
            else
              proc { |other_relation| instance_exec(other_relation, &block) }
            end
          Def::Relationship.new(other_table, relater_proc)
        end
      end

      ##
      # Determine the relationships defined on this table.
      # This is a pretty simple hash of the name of the relationship to the related table.
      # It does not include any information on *how* to obtain that relationship: you need to use
      # the defined instance method on a table instance to get that.
      attr_reader :relationships
      ##
      # The name of this table in Postgres-land.
      # This is anything you want, and we don't default this.
      # TODO: maybe default this to follow some kind of rails conventions?
      attr_accessor :table_name
    end

    def initialize(table_alias)
      @table_alias = table_alias
    end

    def from_clause
      Build::TableFrom.new(self.class.table_name, @table_alias)
    end

    def column(name)
      self.class.columns.fetch(name.to_sym).new(
        Build::Column.new(table_alias, name)
      )
    end

    def columns
      self.class.columns.keys.map do |k|
        column(k)
      end
    end

    def to_select_item
      columns.flat_map(&:to_select_item)
    end

    attr_reader :table_alias
  end
end
