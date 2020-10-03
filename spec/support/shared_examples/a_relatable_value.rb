RSpec.shared_examples 'a relatable value' do
  %i[eq neq lt lt_eq gt gt_eq].each do |v|
    it { should respond_to(v) }
    it "returns a bool with #{v.inspect}" do
      expect(subject.public_send(v, subject)).to be_a(AlgebraDB::Value::Bool)
    end
  end
end
