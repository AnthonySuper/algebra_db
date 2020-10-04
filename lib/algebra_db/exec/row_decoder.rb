module AlgebraDB
  module Exec
    ##
    # Represents a thing that can decode a row.
    class RowDecoder
      def pg_type_map
        PG::TypeMapAllStrings.new
      end

      def decode_row(row)
        row
      end
    end
  end
end
