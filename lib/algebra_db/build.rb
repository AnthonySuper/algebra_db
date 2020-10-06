module AlgebraDB
  ##
  # Namespace for syntax builders.
  #
  # The classes in this namespace all respond to +#render_syntax+, which
  # renders some SQL given a query builder. They are used to generate the actual
  # queries that go to your database.
  module Build
    autoload(:Op, 'algebra_db/build/op')
    autoload(:Between, 'algebra_db/build/between')
    autoload(:Param, 'algebra_db/build/param')
    autoload(:Column, 'algebra_db/build/column')
    autoload(:TableFrom, 'algebra_db/build/table_from')
    autoload(:SelectItem, 'algebra_db/build/select_item')
    autoload(:Join, 'algebra_db/build/join')
    autoload(:SelectList, 'algebra_db/build/select_list')
    autoload(:Into, 'algebra_db/build/into')
    autoload(:InsertValue, 'algebra_db/build/insert_value')
    autoload(:Set, 'algebra_db/build/set')

    ##
    # .param will pass itself as a *raw parameter*.
    # This DOES NOT mean it gets interpolated into the SQL: AlgebraDB *never* does that.
    # Instead, it will simply not be wrapped in a subclass of +AlgebraDB::Value+.
    # This means that it may not be properly typecasted, and that you won't be able to perform
    # operations or call methods on it directly.
    #
    # TODO: Introduce some kinda cool thing where it automatically wraps in the appropriate value type?
    def self.param(value)
      Param.new(value)
    end
  end
end
