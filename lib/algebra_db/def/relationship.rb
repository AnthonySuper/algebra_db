module AlgebraDB
  module Def
    ##
    # Defines a relationship between two tables.
    class Relationship
      def initialize(joined_table, relater_proc)
        @joined_table = joined_table
        @relater_proc = relater_proc
      end

      def join_clause(joined_relation)
        @relater_proc.call(joined_relation)
      end

      def joined_table
        @joined_table.is_a?(Proc) ? @joined_table.call : @joined_table
      end
    end
  end
end
