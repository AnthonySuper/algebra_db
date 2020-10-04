module AlgebraDB
  module Exec
    ##
    # Informational class that holds a decoder.
    class Decoder
      ##
      # The decoder given to postgres for a string.
      def pg_decoder
        PG::TextDecoder::String.new
      end

      ##
      # Post-processing: after we use the pg decoder to load from
      # DB, transform it here! By default, does nothing.
      def decode_value(db_value)
        db_value
      end
    end
  end
end
