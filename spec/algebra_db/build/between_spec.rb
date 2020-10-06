require 'spec_helper'

RSpec.describe AlgebraDB::Build::Between do
  let(:s) { AlgebraDB::Build::Column.new(:t, :s) }
  let(:e) { AlgebraDB::Build::Column.new(:t, :e) }
  let(:t) { AlgebraDB::Build::Column.new(:t, :t) }

  subject(:between) { described_class.new(between_type, t, s, e) }

  {
    between: 'BETWEEN',
    not_between: 'NOT BETWEEN',
    between_symmetric: 'BETWEEN SYMMETRIC',
    not_between_symmetric: 'NOT BETWEEN SYMMETRIC'
  }.each do |k, v|
    context "when used with #{k}" do
      let(:between_type) { k }
      it { should render_syntax(%("t"."t" #{v} "t"."s" AND "t"."e" )) }
    end
  end

  context 'when used with an invalid type' do
    let(:between_type) { :not_a_valid_type }

    specify { expect { subject }.to raise_error(ArgumentError, match(/not_a_valid_type/)) }
  end
end
