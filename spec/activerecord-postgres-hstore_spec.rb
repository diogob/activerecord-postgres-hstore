require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordPostgresHstore" do
  it "should convert hstore string to hash" do
    {:a => 1, :b => 2}.to_hstore.should == "('a'=>'1') || ('b'=>'2')"
  end

  it "should convert hash to hstore string" do
    '"a"=>"1", "b"=>"2"'.from_hstore.should == {'a' => '1', 'b' => '2'}
  end
 
  it "should quote correctly" do
    {:a => "'a'"}.to_hstore.should == "('a'=>'''a''')"
  end
  
end
