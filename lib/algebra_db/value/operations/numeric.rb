module AlgebraDB
  class Value
    module Operations
      ##
      # Operations on numeric-ish types.
      module Numeric
        extend Definition

        binop(:add, :+, :self)
        binop(:subtract, :-, :self)
        binop(:mult, :*, :self)
        binop(:divis, :/, :self)
        binop(:modulo, :%, :self)
        binop(:exp, :^, :Double)
      end
    end
  end
end
