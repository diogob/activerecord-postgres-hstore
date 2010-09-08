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

=begin

  #---

  test "should create contact" do
    assert Contact.make :dynamic_values => {:a => 1, :b => 2}
  end

  test "should raise HstoreTypeMismatch" do
    assert_raises ActiveRecord::HstoreTypeMismatch do
      assert Contact.make :dynamic_values => "bug"
    end
  end

  test "should read values from contact" do
    contact = Contact.make :dynamic_values => {:a => 1, :b => "Lorem ipsum", 'other stuff' => "'''a'''"}
    assert_equal({'a' => '1', 'b' => 'Lorem ipsum', 'other stuff' => "'''a'''"}, Contact.find(contact.id).dynamic_values)
  end

end

=end
