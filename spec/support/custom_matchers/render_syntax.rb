RSpec::Matchers.define :render_syntax do |expected|
  match do |actual|
    @build_actual = actual
    @syntax_builder = AlgebraDB::SyntaxBuilder.new
    actual.render_syntax(@syntax_builder)
    @actual = @syntax_builder.syntax
    v = values_match?(@syntax_builder.syntax, expected)
    v &&= values_match?(params, @syntax_builder.params) if defined?(@params)
    v
  end

  failure_message do |_|
    msg = "expected #{@build_actual} to render syntax #{expected.inspect}"
    msg += " with params #{description_of(params)}" if defined?(@params)
    msg += " but rendered #{@syntax_builder.syntax.inspect}"
    msg += " with params #{@syntax_builder.params.inspect}" if defined?(@params)
    msg += "\nDiff: #{differ.diff_as_string(@syntax_builder.syntax, expected)}"

    msg
  end

  def differ
    RSpec::Support::Differ.new(
      object_preparer: ->(object) { RSpec::Matchers::Composable.surface_descriptions_in(object) },
      color: RSpec::Matchers.configuration.color?
    )
  end

  chain :with_params, :params
  diffable
end
