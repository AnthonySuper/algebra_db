module AlgebraDB
  ##
  # Base class for value types in the DB.
  class Value < Struct.new(:builder) # rubocop:disable Style/StructInheritance
    autoload(:Array, 'algebra_db/value/array')
    autoload(:Text, 'algebra_db/value/text')
    autoload(:Integer, 'algebra_db/value/integer')
    autoload(:Bool, 'algebra_db/value/bool')
    autoload(:Double, 'algebra_db/value/double')
    autoload(:JSONB, 'algebra_db/value/jsonb')
    autoload(:Operations, 'algebra_db/value/operations')

    extend AlgebraDB::Value::Operations::Definition

    def render_syntax(syntax_builder)
      builder.render_syntax(syntax_builder)
    end

    def to_select_item
      unless builder.respond_to?(:default_select_item_alias)
        raise ArgumentError, "#{builder.inspect} has no default alias for us as a select item"
      end

      Build::SelectItem.new(self, builder.default_select_item_alias)
    end

    def decoder
      Exec::Decoder.new
    end

    {
      eq: '=', neq: '<>',
      lt: '<', lt_eq: '<=',
      gt: '>', gt_eq: '>='
    }.each { |k, v| binop(k, v, :Bool) }

    Build::Between::VALID_TYPES.each do |t|
      define_method(t) do |lhs, rhs|
        Value::Bool.new(
          Build::Between.new(t, self, lhs, rhs)
        )
      end
    end
  end
end
