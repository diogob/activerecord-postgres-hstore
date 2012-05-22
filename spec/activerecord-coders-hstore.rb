require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordCodersHstore" do
  it 'should load nil' do
    ActiveRecord::Coders::Hstore.load(nil).should be_nil
  end

  it 'should load an hstore' do
    ActiveRecord::Coders::Hstore.load("a=>a").should == { 'a' => 'a' }
  end

  it 'should dump an hstore' do
    ActiveRecord::Coders::Hstore.dump({'a'=>'a'}).should == {'a'=>'a'}.to_hstore
  end

  it 'should dump nil' do
    ActiveRecord::Coders::Hstore.dump(nil).should be_nil
  end

  it 'should dump the default given nil' do
    ActiveRecord::Coders::Hstore.new({'a'=>'a'}).dump(nil).should == {'a'=>'a'}.to_hstore
  end
end
