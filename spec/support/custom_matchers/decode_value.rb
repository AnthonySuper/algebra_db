RSpec::Matchers.define :decode_value do |expected|
  match do |actual|
    values_match?(actual.decode_value(expected), expected_value)
  end

  chain :to, :expected_value
end
