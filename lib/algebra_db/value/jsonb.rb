module AlgebraDB
  class Value
    ##
    # Represents Postgres JSONB values.
    class JSONB < Value
      ##
      # Decoder just decodes to a hash.
      class Decoder < AlgebraDB::Exec::Decoder
        def pg_decoder
          PG::TextDecoder::JSON.new
        end
      end

      def decoder
        Decoder.new
      end
    end
  end
end
