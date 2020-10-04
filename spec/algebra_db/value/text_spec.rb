RSpec.describe AlgebraDB::Value::Text do
  subject { described_class.new(param) }

  let(:param) { AlgebraDB::Build.param('my text') }

  it { should eq(subject.dup) }

  it_behaves_like 'a relatable value'
end
