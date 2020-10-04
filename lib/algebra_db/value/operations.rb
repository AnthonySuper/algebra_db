module AlgebraDB
  class Value
    ##
    # Easily define operations on values.
    module Operations
      autoload(:Definition, 'algebra_db/value/operations/definition')
      autoload(:Numeric, 'algebra_db/value/operations/numeric')
    end
  end
end
