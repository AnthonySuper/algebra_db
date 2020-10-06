require 'spec_helper'

RSpec.describe AlgebraDB::Value::Integer do
  subject(:value) { described_class.new(param) }
  let(:param) { AlgebraDB::Build.param(1) }

  it_behaves_like 'a relatable value'
  it_behaves_like 'a numeric value'

  describe '#decoder' do
    subject { value.decoder }

    it { should be_a(AlgebraDB::Exec::Decoder) }
    its(:pg_decoder) { should be_a(PG::TextDecoder::Integer) }
  end
end
