module AlgebraDB
  class Value
    ##
    # Represents a Postgres double value.
    class Double < Value
      include Operations::Numeric
      ##
      # Specialization of this decoder.
      class Decoder < AlgebraDB::Exec::Decoder
        def pg_decoder
          PG::TextDecoder::Float.new
        end
      end

      def decoder
        Decoder.new
      end
    end
  end
end
