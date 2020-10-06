module AlgebraDB
  module Exec
    ##
    # Something we can hand off to a connection
    # to get back ruby values to play with.
    class Delivery
      def initialize(query_builder, select_decoder)
        @query_builder = query_builder
        @select_decoder = select_decoder
      end

      def returns_values?
        !@select_decoder.nil?
      end

      def execute!(connection)
        return enum_for(:execute!, connection) unless block_given?

        execute_raw!(connection) do |result|
          result.type_map = @select_decoder.pg_type_map if @select_decoder
          result.each do |row|
            yield @select_decoder.decode_row(row)
          end
        end
      end

      ##
      # Execute a query raw, IE, don't do decoding.
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
