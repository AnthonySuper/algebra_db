require 'algebra_db/version'
##
# Root namespace for the gem.
module AlgebraDB
  class Error < StandardError; end
  autoload(:Build, 'algebra_db/build')
  autoload(:Value, 'algebra_db/value')
  autoload(:SyntaxBuilder, 'algebra_db/syntax_builder')
  autoload(:Statement, 'algebra_db/statement')
  autoload(:Table, 'algebra_db/table')
  # Your code goes here...
end
