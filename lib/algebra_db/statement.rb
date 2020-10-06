module AlgebraDB
  ##
  # Namespace for statement modules.
  module Statement
    autoload(:Select, 'algebra_db/statement/select')
    autoload(:Insert, 'algebra_db/statement/insert')
  end
end
