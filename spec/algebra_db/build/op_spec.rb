RSpec.describe AlgebraDB::Build::Op do
  let(:lhs) { AlgebraDB::Build::Column.new(:users, :id) }
  let(:rhs) { AlgebraDB::Build::Column.new(:posts, :user_id) }
  subject { described_class.new('=', lhs, rhs) }

  it { should render_syntax(%("users"."id" = "posts"."user_id" )) }
  its(:lhs) { should eq lhs }
  its(:operator) { should eq '=' }
  its(:rhs) { should eq rhs }
end
