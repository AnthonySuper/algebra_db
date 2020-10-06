module AlgebraDB
  module Exec
    ##
    # AlgebraDB Statements return a +Delivery+ instead of raw values.
    # You can then use this delivery with a connection to get the Ruby values you want.
    # This is intentional, as it makes writing N+1 queries very difficult without it being very obvious
    # what is going on!
    #
    # TODO: Add some kind of transactional executor that executes deliveries in the context of a connection
    class Delivery
      def initialize(query_builder, select_decoder)
        @query_builder = query_builder
        @select_decoder = select_decoder
      end

      def returns_values?
        !@select_decoder.nil?
      end

      ##
      # Execute this delivery in the context of the given connection.
      #
      # :call-seq:
      #
      #   delivery.execute!(conn) { |r| puts r } -> nil
      #   delivery.execute!(conn) -> Enumerator
      #   delviery.execute!(conn).to_a -> Array
      def execute!(connection)
        return enum_for(:execute!, connection) unless block_given?

        execute_raw!(connection) do |result|
          result.type_map = @select_decoder.pg_type_map if @select_decoder
          result.each do |row|
            yield @select_decoder.decode_row(row)
          end
        end

        nil
      end

      ##
      # Execute a query raw, without decoding.
      def execute_raw!(connection)
        sb = SyntaxBuilder.new.tap { |t| @query_builder.render_syntax(t) }
        # rubocop:disable Style/ExplicitBlockArgument
        connection.exec_params(sb.syntax, sb.params) do |res|
          yield res
        end
        # rubocop:enable Style/ExplicitBlockArgument
      end
    end
  end
end
