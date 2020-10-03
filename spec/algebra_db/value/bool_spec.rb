RSpec.describe AlgebraDB::Value::Bool do
  subject { described_class.new(AlgebraDB::Build.param(true)) }

  its(:builder) { should eq(AlgebraDB::Build.param(true)) }
  it { should respond_to(:and).with(1).argument }
  it { should respond_to(:or).with(1).argument }

  it 'ANDs with itself' do
    expect(subject.and(subject)).to be_a(described_class)
  end

  it 'ORs witth itself' do
    expect(subject.or(subject)).to be_a(described_class)
  end

  it_behaves_like 'a relatable value'
end
