require 'spec_helper'

RSpec.describe AlgebraDB::Statement::Insert do
  describe '#insert_hash' do
    let(:valid_syntax) do
      'INSERT INTO users(first_name, last_name) '\
        'VALUES ($1, $2) RETURNING '\
        '"users"."id" AS "id", "users"."first_name" AS "first_name", '\
        '"users"."last_name" AS "last_name" '
    end

    shared_examples 'a valid run' do
      it { should be_a(described_class) }
      it { should be_returns_values }
      its(:to_delivery) { should be_returns_values }
      it do
        should(
          render_syntax(
            valid_syntax
          ).with_params(%w[Rich Evans])
        )
      end
    end

    context 'with a single valid hash' do
      subject do
        described_class.insert_hash(
          UserTable,
          { first_name: 'Rich', last_name: 'Evans' }
        )
      end
      it_behaves_like 'a valid run'
    end

    context 'with an array of valid hashes' do
      subject do
        described_class.insert_hash(
          UserTable,
          [{ first_name: 'Rich', last_name: 'Evans' }]
        )
      end
      it_behaves_like 'a valid run'
    end
  end

  describe '#run_syntax' do
    it 'raises an error when returning early' do
      expect do
        described_class.run_syntax do
          returning(%i[id])
          insert(UserTable, %i[first_name last_name])
          values(param('Bob'), param('Smith'))
        end
      end.to raise_error(ArgumentError, match(/use #into first/))
    end

    it 'raises an error when returning twice' do
      expect do
        described_class.run_syntax do
          into(UserTable, %i[first_name])
          value(param('Bob'))
          returning(%i[id])
          returning(%i[id first_name])
        end
      end.to raise_error(ArgumentError, match(/returning/) & match(/twice/))
    end

    it 'raises an error when returning bad columns' do
      expect do
        described_class.run_syntax do
          into(UserTable, %i[first_name])
          value(param('Bob'))
          returning(%i[id not_a_column])
        end
      end.to raise_error(ArgumentError, match(/not_a_column/))
    end

    context 'when used with no returning' do
      subject do
        described_class.run_syntax do
          into(UserTable, %i[first_name])
          value(param('Bob'))
        end
      end

      it { should_not be_returns_values }
      it { should render_syntax('INSERT INTO users(first_name) VALUES ($1) ').with_params(contain_exactly('Bob')) }
      its(:to_delivery) { should_not be_returns_values }
    end
  end

  describe 'use with subselects' do
    shared_examples 'a proper subselect' do
      specify { expect { subject }.to_not raise_error }
      it { should_not be_nil }
      it do
        syntax =
          'INSERT INTO user_audits(user_id) SELECT "t_1"."id" AS "user_id" FROM users t_1 '
        should(render_syntax(syntax))
      end
    end

    context 'when used with a select statement' do
      subject do
        s = select
        described_class.run_syntax do
          into(UserAuditTable, :user_id)
          select(s)
        end
      end

      let(:select) do
        AlgebraDB::Statement::Select.run_syntax do
          users = all(UserTable)
          select(user_id: users.id)
        end
      end
      it_behaves_like 'a proper subselect'
    end

    context 'when used with a select block' do
      subject do
        described_class.run_syntax do
          into(UserAuditTable, :user_id)
          select do
            users = all(UserTable)
            select(user_id: users.id)
          end
        end
      end
      it_behaves_like 'a proper subselect'
    end

    it 'fails when you also try to specify values' do
      expect do
        described_class.run_syntax do
          into(UserAuditTable, :user_id)
          select { select(user_id: all(UserTable).id) }
          value(param(1))
        end
      end.to raise_error(ArgumentError)
    end

    it 'fails when you have already specified values' do
      expect do
        described_class.run_syntax do
          into(UserAuditTable, :user_id)
          value(param(1))
          select { select(user_id: all(UserTable).id) }
        end
      end.to raise_error(ArgumentError)
    end

    it 'fails when you try twice' do
      expect do
        described_class.run_syntax do
          into(UserAuditTable, :user_id)
          select { select(user_id: all(UserTable).id) }
          select { select(user_id: all(UserTable).id.add(raw_param(1))) }
        end
      end.to raise_error(ArgumentError, match(/already/))
    end
  end
end
