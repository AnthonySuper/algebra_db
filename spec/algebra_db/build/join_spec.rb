require 'spec_helper'

RSpec.describe AlgebraDB::Build::Join do
  let(:table) { AlgebraDB::Build::TableFrom.new(:t, :t) }
  let(:cond) { AlgebraDB::Build.param(true) }

  subject { described_class.new(type, table, cond) }

  context 'with an :inner type' do
    let(:type) { :inner }
    it { should render_syntax('INNER JOIN t t ON $1 ') }
  end

  context 'with a :left type' do
    let(:type) { :left }
    it { should render_syntax('LEFT OUTER JOIN t t ON $1 ') }
  end

  context 'with a :right type' do
    let(:type) { :right }

    it { should render_syntax('RIGHT OUTER JOIN t t ON $1 ') }
  end

  context 'with an :inner_lateral type' do
    let(:type) { :inner_lateral }
    it { should render_syntax('INNER JOIN LATERAL t t ON $1 ') }
  end

  context 'with a :left_lateral type' do
    let(:type) { :left_lateral }

    it { should render_syntax('LEFT JOIN LATERAL t t ON $1 ') }
  end

  context 'with a :right_lateral type' do
    let(:type) { :right_lateral }

    it { should render_syntax('RIGHT JOIN LATERAL t t ON $1 ') }
  end

  context 'when used with an invalid type' do
    let(:type) { :not_a_join_lol }

    specify do
      expect { subject }.to raise_error(ArgumentError, match(/not_a_join_lol/))
    end
  end
end
