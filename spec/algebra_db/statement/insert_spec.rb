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
end
