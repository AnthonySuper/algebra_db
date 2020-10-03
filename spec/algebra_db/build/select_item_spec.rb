require 'spec_helper'

RSpec.describe AlgebraDB::Build::SelectItem do
  context 'with a column' do
    let(:column) { AlgebraDB::Build::Column.new(:tbl_1, :id) }
    subject(:select) { described_class.new(column, :id) }
    it { should render_syntax(%("tbl_1"."id" AS "id" )) }
    its(:value) { should eq column }
    its(:select_alias) { should eq :id }
  end
end
