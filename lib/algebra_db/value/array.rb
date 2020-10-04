module AlgebraDB
  class Value
    ##
    # Represents Postgres arrays with an inner type.
    class Array < Value
      def self.of(other)
        Class.new(other) do
          include AlgebraDB::Value::Array::ArrayOps

          def decoder
            AlgebraDB::Value::Array::Decoder.new(super)
          end
        end
      end
      ##
      # Decodes into ruby arrays.
      class Decoder < AlgebraDB::Exec::Decoder
        def initialize(inner_decoder) # rubocop:disable Lint/MissingSuper
          @inner_decoder = inner_decoder
        end

        def pg_decoder
          PG::TextDecoder::Array.new.tap do |decoder|
            decoder.elements_type = @inner_decoder.pg_decoder
          end
        end

        def decode_value(db_value)
          db_value.map { |v| @inner_decoder.decode_value(v) }
        end
      end

      ##
      # Array operations, mixed into generated array value classes.
      module ArrayOps
        extend Operations::Definition

        binop(:contains, :'@>', :Bool)
        binop(:is_contained_by, :'<@', :Bool)
        binop(:overlaps, :'&&', :Bool)
        binop(:concat, :'||', :Bool)
      end

      def decoder
        AlgebraDB::Value::Array::Decoder.new(builder.decoder)
      end

      # Convenience constants
      Text = of(::AlgebraDB::Value::Text)
      Double = of(::AlgebraDB::Value::Double)
      Integer = of(::AlgebraDB::Value::Integer)
      JSONB = of(::AlgebraDB::Value::JSONB)
    end
  end
end
