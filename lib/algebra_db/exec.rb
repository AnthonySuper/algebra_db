module AlgebraDB
  ##
  # Namespace for things that execute queries, and helpers.
  module Exec
    autoload(:Delivery, 'algebra_db/exec/delivery')
    autoload(:Decoder, 'algebra_db/exec/decoder')
    autoload(:RowDecoder, 'algebra_db/exec/row_decoder')
  end
end
