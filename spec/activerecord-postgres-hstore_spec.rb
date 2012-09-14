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

  it "should print a warning if symbol keys are used" do
    Kernel.should_receive(:warn)
    {:a => 1}.to_hstore
  end

  it "should convert hash to hstore string" do
    {"a" => "alpha", "b" => "bravo"}.to_hstore.should eq('a=>alpha,b=>bravo')
  end

  it "should convert hstore string to hash" do
    '"a"=>"alpha","b"=>"bravo"'.from_hstore.should eq({"a" => "alpha", "b" => "bravo"})
  end

  it "should preserve literal values" do
    hash = {"a" => 1, "b" => true}
    hash.to_hstore.from_hstore.should eq(hash)
  end

  it "should quote correctly" do
    {"'a'" => "'alpha'"}.to_hstore.should eq("'a'=>'alpha'")
  end

  it "should store nil as NULL" do
    {'a' => nil}.to_hstore.should eq("a=>NULL")
  end

  it "should retrive NULL (case insensitive) as nil" do
    "a=>NULL,b=>NuLl".from_hstore.should eq({"a"=>nil,"b"=>nil})
  end

  it "should retreive quoted NULL as string" do
    'a=>"NULL"'.from_hstore.should eq({"a"=>"NULL"})
  end

  it "should not allow nil keys" do
    lambda{ {nil => 'a'}.to_hstore; }.should raise_error
  end

  it "should quote tokens with space, comma, equals or greaterthan" do
    {' '=>' '}.to_hstore.should eq(%q(" "=>" "))
    {','=>','}.to_hstore.should eq(%q(","=>","))
    {'='=>'='}.to_hstore.should eq(%q("="=>"="))
    {'>'=>'>'}.to_hstore.should eq(%q(">"=>">"))
  end

  it "should unquote keys correctly with single quotes" do
    "\"'a'\"=>\"a\"". from_hstore.should eq({"'a'" => "a"})
    '\=a=>q=w'.       from_hstore.should eq({"=a"=>"q=w"})
    '"=a"=>q\=w'.     from_hstore.should eq({"=a"=>"q=w"});
    '"\"a"=>q>w'.     from_hstore.should eq({"\"a"=>"q>w"});
    '\"a=>q"w'.       from_hstore.should eq({"\"a"=>"q\"w"})
  end

  it "should quote keys and values correctly with combinations of single and double quotes" do
    { %q("a') => %q(b "a' b) }.to_hstore.should eq(%q(\"a'=>"b \"a' b"))
  end

  it "should unquote keys and values correctly with combinations of single and double quotes" do
    %q("\"a'"=>"b \"a' b").from_hstore.should eq({%q("a') => %q(b "a' b)})
  end

  it "should store empty hash" do
    {}.to_hstore.should eq("")
  end

  it "should retrieve empty string" do
    ''.from_hstore.should eq({})
  end

  it "should retrieve blank string" do
    '    '.from_hstore.should eq({})
  end

  # Line breaks
  it "should not change values with line breaks" do
    input = { "a" => "foo\nbar" }
    input.to_hstore.from_hstore.should eq(input)
  end

  # Nested hashes
  it "should convert complex hash to hstore string" do
    hash = {"name" => {"first" => "David", "last" => "Smith"}}
    hash.to_hstore.should eq(%q(name=>"{first=>David,last=>Smith}"))
  end

  it "should convert a complex hstore string to a hash" do
    hash = {"name" => {"first" => "David", "last" => "Smith"}}
    %q(name=>"{first=>David,last=>Smith}").from_hstore.should eq(hash)
  end

  # Backslashes
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
end
