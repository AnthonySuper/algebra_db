require 'spec_helper'

RSpec.describe AlgebraDB::Table do
  context 'with a basic table' do
    subject(:table) do
      Class.new(described_class) do
        self.table_name = :users
        column :first_name, :Text
        column :last_name, :Text
        column :cool, :Bool
      end
    end

    it { should be_column(:cool) }
    it { should be_column(:first_name) }
    it { should be_column(:last_name) }

    context 'value usage' do
      subject { table.new(:tbl_1) }

      its(:first_name) { should render_syntax(%("tbl_1"."first_name" )) }
      its(:first_name) { should be_a(AlgebraDB::Value::Text) }
      its(:last_name) { should be_a(AlgebraDB::Value::Text) }
      its(:cool) { should be_a(AlgebraDB::Value::Bool) }
      its(:from_clause) { should render_syntax(%(users tbl_1 )) }
    end
  end
end
