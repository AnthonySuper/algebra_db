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
    end
  end
end
