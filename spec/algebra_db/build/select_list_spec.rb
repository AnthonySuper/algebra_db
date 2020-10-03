require 'spec_helper'

RSpec.describe AlgebraDB::Build::SelectList do
  context 'with a hash' do
    let(:id_col) { AlgebraDB::Build::Column.new(:tbl_1, :id) }
    let(:name_col) { AlgebraDB::Build::Column.new(:tbl_2, :name) }
    subject(:select) do
      described_class.new(id_col, name_alias: name_col)
    end
    it do
      should render_syntax(%("tbl_1"."id" AS "id", "tbl_2"."name" AS "name_alias" ))
    end

    context 'with duplicate keys' do
      subject(:select) do
        described_class.new(id_col, id: name_col)
      end
      specify { expect { subject }.to raise_error(ArgumentError, match(/id/)) }
    end
  end
end
