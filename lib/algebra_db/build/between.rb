module AlgebraDB
  module Build
    ##
    # A BETWEEN expression builder.
    class Between < Struct.new(:between_type, :choose, :start, :finish) # rubocop:disable Style/StructInheritance
      VALID_TYPES =
        %i[between not_between between_symmetric not_between_symmetric].freeze
      def initialize(between_type, choose, start, finish)
        super(between_type, choose, start, finish)

        return if VALID_TYPES.include?(between_type)

        raise ArgumentError, "#{between_type} must be one of #{VALID_TYPES.inspect}"
      end

      def render_syntax(builder)
        choose.render_syntax(builder)
        builder.text(between_type.to_s.gsub('_', ' ').upcase)
        start.render_syntax(builder)
        builder.text('AND')
        finish.render_syntax(builder)
      end
    end
  end
end
