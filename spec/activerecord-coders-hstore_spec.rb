require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveRecord::Coders::Hstore do
  describe "#load" do
    subject{ ActiveRecord::Coders::Hstore.new.load(value) }

    context 'when value is nil and we have a default in the constructor' do
      subject{ ActiveRecord::Coders::Hstore.new({'a'=>'a'}).load(nil) }
      it{ should eql({'a'=>'a'}) }
    end

    context 'when key and value have newline char' do
      let(:value){ "\"foo\nbar\"=>\"\nnewline\"" }
      it{ should eql({"foo\nbar" => "\nnewline"}) }
    end

    context 'when key and value are empty strings' do
      let(:value){ %q(""=>"") }
      it{ should eql({'' => ''}) }
    end

    context 'when value has single quotes' do
      let(:value){ %q("'a'"=>"'a'") }
      it{ should eql({"'a'" => "'a'"}) }
    end

    context 'when value is empty hash' do
      let(:value){ '' }
      it{ should eql({}) }
    end

    context 'when value is nil' do
      let(:value){ nil }
      it { should be_nil }
    end

    context 'when value is a hstore' do
      let(:value){ "a=>a" }
      it{ should eql({ 'a' => 'a' }) }
    end
  end

  describe "#dump" do
    subject{ ActiveRecord::Coders::Hstore.new.dump(value) }

    context 'when value is nil and we have a default in the constructor' do
      subject{ ActiveRecord::Coders::Hstore.new({'a'=>'a'}).dump(nil) }
      it{ should eql('"a"=>"a"') }
    end

    context 'when key and value have dollar sign char' do
      let(:value){ {"foo$bar" => "$ 5.00"} }
      it{ should eql("\"foo$bar\"=>\"$ 5.00\"") }
    end

    context 'when key and value have newline char' do
      let(:value){ {"foo\nbar" => "\nnewline"} }
      it{ should eql("\"foo\nbar\"=>\"\nnewline\"") }
    end

    context 'when key and value are empty strings' do
      let(:value){ {'' => ''} }
      it{ should eql(%q(""=>"")) }
    end

    context 'when value has single quotes' do
      let(:value){ {"'a'" => "'a'"} }
      it{ should eql(%q("'a'"=>"'a'")) }
    end

    context 'when value is empty hash' do
      let(:value){ {} }
      it{ should eql('') }
    end

    context 'when value is nil' do
      let(:value){ nil }
      it{ should be_nil }
    end

    context "when value is an hstore" do
      let(:value){ {'a' => 'a'} }
      it{ should eql('"a"=>"a"') }
    end

    context 'when value has double quotes' do
      let(:value){ {"a" => "\"a\""} }
      it{ should eql(%q("a"=>"\"a\"")) }
    end

    # @seamusabshere not sure about this test
    # context 'when value has double-escaped double quotes' do
    #   let(:value){ {"a" => "\\\"a\\\""} }
    #   it{ should eql(%q("a"=>"\"a\"")) }
    # end
  end

  describe ".load" do
    before do
      @parameter = 'b=>b'
      instance = double("coder instance")
      instance.should_receive(:load).with(@parameter)
      ActiveRecord::Coders::Hstore.should_receive(:new).and_return(instance)
    end

    it("should instantiate and call load") do
      ActiveRecord::Coders::Hstore.load(@parameter)
    end
  end

  describe ".dump" do
    before do
      @parameter = {'b' => 'b'}
      instance = double("coder instance")
      instance.should_receive(:dump).with(@parameter)
      ActiveRecord::Coders::Hstore.should_receive(:new).and_return(instance)
    end

    it("should instantiate and call dump") do
      ActiveRecord::Coders::Hstore.dump(@parameter)
    end
  end
end
