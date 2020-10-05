require 'spec_helper'

RSpec.describe AlgebraDB::Statement::Select do
  let(:users) do
    Class.new(AlgebraDB::Table) do
      self.table_name = :users
      column :first_name, :Text
      column :last_name, :Text
    end
  end

  context 'with a very basic case' do
    subject(:query) do
      u = users
      described_class.run_syntax do
        users = all(u)
        select(users)
      end
    end

    it do
      expect = 'SELECT "t_1"."first_name" AS "first_name", "t_1"."last_name" AS "last_name" FROM users t_1 '
      should render_syntax(expect)
    end
  end

  context 'with some wheres' do
    subject(:query) do
      u = users
      described_class.run_syntax do
        users = all(u)
        where(users.first_name.eq(users.last_name))
        select(users.first_name)
      end
    end

    it do
      expect =
        'SELECT "t_1"."first_name" AS "first_name" ' \
        'FROM users t_1 WHERE ("t_1"."first_name" = "t_1"."last_name") '
      should render_syntax(expect)
    end
  end
end
