module AlgebraDB
  class Value
    ##
    # Represent a postgres TEXT value.
    class Text < Value
      binop(:append, '||', :Text)
    end
  end
end
