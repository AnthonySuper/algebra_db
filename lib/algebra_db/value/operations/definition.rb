module AlgebraDB
  class Value
    module Operations
      ##
      # Base class that provides a DSL to quickly define things.
      module Definition
        def binop(name, pg_name, ret_val) # rubocop:disable Metrics/MethodLength
          method_body =
            if ret_val == :self
              proc do |rhs|
                op = ::AlgebraDB::Build::Op.new(pg_name, self, rhs)
                self.class.new(op)
              end
            else
              ret_type = ::AlgebraDB::Value.const_get(ret_val)
              proc { |rhs| ret_type.new(::AlgebraDB::Build::Op.new(pg_name, self, rhs)) }
            end
          define_method(name, &method_body)
        end
      end
    end
  end
end
