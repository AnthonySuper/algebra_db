module AlgebraDB
  class Value
    ##
    # Represents a Postgres boolean value.
    class Bool < Value
      def and(other)
        Value::Bool.new(
          Build::Op.new('AND', self, other)
        )
      end

      def or(other)
        Value::Bool.new(
          Build::Op.new('OR', self, other)
        )
      end

      ##
      # Specialization of this decoder.
      class Decoder < AlgebraDB::Exec::Decoder
        def decode_value(db_value)
          db_value == 't'
        end
      end

      def decoder
        Decoder.new
      end
    end
  end
end
