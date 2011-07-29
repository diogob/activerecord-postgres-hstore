require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordPostgresHstore" do

  it "should convert hash to hstore string" do
    ["('a'=>'1') || ('b'=>'2')", "('b'=>'2') || ('a'=>'1')"].should include({:a => 1, :b => 2}.to_hstore)
  end

  it "should convert hstore string to hash" do
    '"a"=>"1", "b"=>"2"'.from_hstore.should eq({'a' => '1', 'b' => '2'})
  end
 
  it "should quote correctly" do
    {:a => "'a'"}.to_hstore.should eq("('a'=>'''a''')")
  end

  it "should quote keys correctly" do
    {"'a'" => "a"}.to_hstore.should  eq("('''a'''=>'a')")
  end

  it "should unquote keys correctly" do
    "\"'a'\"=>\"a\"".from_hstore.should eq({"'a'" => "a"})
  end

  it "should convert empty hash" do
    {}.to_hstore.should eq("''")
  end

  it "should convert empty string" do
    ''.from_hstore.should eq({})
  end
  
end
