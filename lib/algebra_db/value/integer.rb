module AlgebraDB
  class Value
    ##
    # Represents a Postgres integer value.
    class Integer < Value
      include Operations::Numeric
      ##
      # Specialization of this decoder.
      class Decoder < AlgebraDB::Exec::Decoder
        def pg_decoder
          PG::TextDecoder::Integer.new
        end
      end

      def decoder
        Decoder.new
      end
    end
  end
end
