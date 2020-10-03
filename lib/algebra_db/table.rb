module AlgebraDB
  ##
  # Represent a table in AlgebraDB.
  # You should subclass this for your own tables.
  #
  # You should not call #new on this directly.
  # Instead, use the *class* in a syntax runner.
  class Table
    class << self
      def columns
        (@columns || {}).dup
      end

      def column(name, value)
        value = ::AlgebraDB::Value.const_get(value) if value.is_a?(Symbol)
        @columns ||= {}
        @columns[name.to_sym] = value
        define_method(name) do
          value.new(Build::Column.new(table_alias, name))
        end
      end

      def column?(name)
        columns.key?(name.to_sym)
      end

      def to_relation(relation_alias)
        new(relation_alias)
      end

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
