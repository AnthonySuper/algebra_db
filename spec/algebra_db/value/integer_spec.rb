require 'spec_helper'

RSpec.describe AlgebraDB::Value::Integer do
  subject { described_class.new(param) }
  let(:param) { AlgebraDB::Build.param(1) }

  it_behaves_like 'a relatable value'
  it_behaves_like 'a numeric value'
end
