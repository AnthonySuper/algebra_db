module AlgebraDB
  ##
  # Namespace for syntax builders.
  module Build
    autoload(:Op, 'algebra_db/build/op')
    autoload(:Between, 'algebra_db/build/between')
    autoload(:Param, 'algebra_db/build/param')
    autoload(:Column, 'algebra_db/build/column')
    autoload(:TableFrom, 'algebra_db/build/table_from')
    autoload(:SelectItem, 'algebra_db/build/select_item')
    autoload(:Join, 'algebra_db/build/join')
    autoload(:SelectList, 'algebra_db/build/select_list')

    ##
    # Returns a raw parameter builder, with no value type.
    def self.param(value)
      Param.new(value)
    end
  end
end
