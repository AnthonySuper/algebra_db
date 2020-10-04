RSpec.describe AlgebraDB::Value::Bool do
  subject(:value) { described_class.new(AlgebraDB::Build.param(true)) }

  its(:builder) { should eq(AlgebraDB::Build.param(true)) }
  it { should respond_to(:and).with(1).argument }
  it { should respond_to(:or).with(1).argument }

  it 'ANDs with itself' do
    expect(subject.and(subject)).to be_a(described_class)
  end

  it 'ORs witth itself' do
    expect(subject.or(subject)).to be_a(described_class)
  end

  describe 'decoder' do
    subject { value.decoder }
    it { should decode_value('t').to(true) }
    it { should decode_value('f').to(false) }
  end

  it_behaves_like 'a relatable value'
end
