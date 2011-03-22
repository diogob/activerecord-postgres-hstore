require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordPostgresHstore" do

  it "should convert hstore string to hash" do
    ["('a'=>'1') || ('b'=>'2')", "('b'=>'2') || ('a'=>'1')"].should include({:a => 1, :b => 2}.to_hstore)
  end

  it "should convert hash to hstore string" do
    {:a => 1, :b => 2}.to_hstore.should == "('a'=>'1') || ('b'=>'2')"
  end

  it "should convert hstore string to hash" do
    '"a"=>"1", "b"=>"2"'.from_hstore.should == {'a' => '1', 'b' => '2'}
  end
 
  it "should quote correctly" do
    {:a => "'a'"}.to_hstore.should == "('a'=>'''a''')"
  end

  it "should convert empty hash" do
    {}.to_hstore.should == "''"
  end

  it "should convert empty string" do
    ''.from_hstore.should == {}
  end

  context "validation" do

    it "should pass for a blank string" do
      "".valid_hstore?.should == true
    end

    it "should pass for double quoted hstore format" do
      %("foo"=>"bar").valid_hstore?.should == true
    end

    it "should pass for single quoted hstore format" do
      %('foo'=>'bar').valid_hstore?.should == true
    end

    it "should pass for single quoted hstore format" do
      %(:foo =>'bar').valid_hstore?.should == true
    end

  end

end
