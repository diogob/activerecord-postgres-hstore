require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordPostgresHstore" do
  it "should recognize a valid hstore string" do
    "".valid_hstore?.should be_true
    "a=>b".valid_hstore?.should be_true
    '"a"=>"b"'.valid_hstore?.should be_true
    '"a" => "b"'.valid_hstore?.should be_true
    '"a"=>"b","c"=>"d"'.valid_hstore?.should be_true
    '"a"=>"b", "c"=>"d"'.valid_hstore?.should be_true
    '"a" => "b", "c"=>"d"'.valid_hstore?.should be_true
    '"a"=>"b","c" => "d"'.valid_hstore?.should be_true
    'k => v'.valid_hstore?.should be_true
    'foo => bar, baz => whatever'.valid_hstore?.should be_true
    '"1-a" => "anything at all"'.valid_hstore?.should be_true
    'key => NULL'.valid_hstore?.should be_true
    %q(c=>"}", "\"a\""=>"b \"a b").valid_hstore?.should be_true
  end

  it "should not recognize an invalid hstore string" do
    '"a"=>"b",Hello?'.valid_hstore?.should be_false
  end

  it "should convert hash to hstore string and back (sort of)" do
    {:a => 1, :b => 2}.to_hstore.from_hstore.should eq({"a" => "1", "b" => "2"})
  end

  it "should convert hstore string to hash" do
    '"a"=>"1", "b"=>"2"'.from_hstore.should eq({'a' => '1', 'b' => '2'})
  end
 
  it "should quote correctly" do
    {:a => "'a'"}.to_hstore.should eq(%q(a=>'a'))
  end

  it "should quote keys correctly" do
    {"'a'" => "a"}.to_hstore.should eq(%q('a'=>a))
  end

  it "should preserve null values on store" do
    # NULL=>b will be interpreted as the string pair "NULL"=>"b"

    {'a' => nil,nil=>'b'}.to_hstore.should eq(%q(a=>NULL,NULL=>b))
  end

  it "should preserve null values on load" do
    'a=>null,b=>NuLl,c=>"NuLl",null=>c'.from_hstore.should eq({'a'=>nil,'b'=>nil,'c'=>'NuLl','null'=>'c'})
  end

  it "should quote tokens with nothing space comma equals or greaterthan" do
    {' '=>''}.to_hstore.should eq(%q(" "=>""))
    {','=>''}.to_hstore.should eq(%q(","=>""))
    {'='=>''}.to_hstore.should eq(%q("="=>""))
    {'>'=>''}.to_hstore.should eq(%q(">"=>""))
  end

  it "should unquote keys correctly with single quotes" do
    "\"'a'\"=>\"a\"". from_hstore.should eq({"'a'" => "a"})
    '\=a=>q=w'.       from_hstore.should eq({"=a"=>"q=w"})
    '"=a"=>q\=w'.     from_hstore.should eq({"=a"=>"q=w"});
    '"\"a"=>q>w'.     from_hstore.should eq({"\"a"=>"q>w"});
    '\"a=>q"w'.       from_hstore.should eq({"\"a"=>"q\"w"})
  end

  it "should quote keys and values correctly with combinations of single and double quotes" do
    { %q("a') => %q(b "a' b) }.to_hstore.should eq(%q("\"a'"=>"b \"a' b"))
  end

  it "should unquote keys and values correctly with combinations of single and double quotes" do
    %q("\"a'"=>"b \"a' b").from_hstore.should eq({%q("a') => %q(b "a' b)})
  end

  it "should quote keys and values correctly with backslashes" do
    { %q(\\) => %q(\\) }.to_hstore.should eq(%q("\\\\"=>"\\\\"))
  end
  
  it "should unquote keys and values correctly with backslashes" do
    %q("\\\\"=>"\\\\").from_hstore.should eq({ %q(\\) => %q(\\) })
  end

  it "should quote keys and values correctly with combinations of backslashes and quotes" do
    { %q(' \\ ") => %q(" \\ ') }.to_hstore.should eq(%q("' \\\\ \""=>"\" \\\\ '"))
  end

  it "should unquote keys and values correctly with combinations of backslashes and quotes" do
    %q("' \\\\ \""=>"\" \\\\ '").from_hstore.should eq({ %q(' \\ ") => %q(" \\ ') })
  end

  it "should convert empty hash" do
    {}.to_hstore.should eq("")
  end

  it "should convert empty string" do
    ''.from_hstore.should eq({})
    '         '.from_hstore.should eq({})
  end

  it "should not change values with line breaks" do
    input = { "a" => "foo\n\nbar" }
    output = input.to_hstore
    output.from_hstore.should eq(input)
  end
  
end
