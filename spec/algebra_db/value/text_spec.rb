RSpec.describe AlgebraDB::Value::Text do
  let(:param) { AlgebraDB::Build.param('my text') }
  it { should eq(subject.dup) }
  subject { described_class.new(param) }

  it_behaves_like 'a relatable value'
end
