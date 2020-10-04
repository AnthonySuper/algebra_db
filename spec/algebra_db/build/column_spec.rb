RSpec.describe AlgebraDB::Build::Column do
  subject { described_class.new(:table, :column) }
  it { should render_syntax(%("table"."column" )).with_params(be_empty) }
  its(:table) { should eq :table }
  its(:column) { should eq :column }
  it { should eq described_class.new(:table, :column) }
end
