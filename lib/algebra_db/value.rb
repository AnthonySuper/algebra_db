module AlgebraDB
  ##
  # Base class for value types in the DB.
  Value = Struct.new(:builder) do # rubocop:disable Metrics/BlockLength
    autoload(:Text, 'algebra_db/value/text')
    autoload(:Bool, 'algebra_db/value/bool')

    def render_syntax(syntax_builder)
      builder.render_syntax(syntax_builder)
    end

    def to_select_item
      builder.to_select_item
    end

    {
      eq: '=',
      neq: '<>',
      lt: '<',
      lt_eq: '<=',
      gt: '>',
      gt_eq: '>='
    }.each do |k, v|
      define_method(k) do |other|
        AlgebraDB::Value::Bool.new(
          AlgebraDB::Build::Op.new(
            v,
            self,
            other
          )
        )
      end
    end
  end
end
