require 'spec_helper'

RSpec.describe AlgebraDB::Build::SelectItem do
  context 'with a column' do
    let(:column) { AlgebraDB::Build::Column.new(:tbl_1, :id) }
    subject(:select) { described_class.new(column, :id) }
    it { should render_syntax(%("tbl_1"."id" AS "id" )) }
    its(:value) { should eq column }
    its(:select_alias) { should eq :id }
  end

  it 'raises an error when given nil for a value' do
    expect do
      described_class.new(nil, :alias)
    end.to raise_error(ArgumentError, match(/value/) & match(/nil/))
  end

  it 'raises an error when given nil for an alias' do
    expect do
      described_class.new(AlgebraDB::Build.param(1), nil)
    end.to raise_error(ArgumentError, match(/select_alias/) & match(/nil/))
  end
end
