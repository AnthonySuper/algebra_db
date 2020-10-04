RSpec.shared_examples 'a numeric value' do
  %i[add subtract mult divis modulo exp].each do |v|
    it { should respond_to(v).with(1).argument }
  end
end
