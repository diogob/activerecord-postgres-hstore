require File.dirname(__FILE__) + '/../test_helper'


class BarTest < ActiveSupport::TestCase

  test "should create contact" do
    assert Bar.create :data => {:a => 1, :b => 2}
  end

  test "should raise HstoreTypeMismatch" do
    assert_raises ActiveRecord::HstoreTypeMismatch do
      assert Bar.create :data => "bug"
    end
  end

  test "should read values from contact" do
    bar = Bar.create :data => {:a => 1, :b => "Lorem ipsum", 'other stuff' => "'''a'''"}
    assert_equal({'a' => '1', 'b' => 'Lorem ipsum', 'other stuff' => "'''a'''"}, Bar.find(bar.id).data)
  end

  test "should search" do
    Array.new(10){|i|
      Bar.create :data => {:a => "value#{i}"}
    }
    assert_equal 10, Bar.where("data ? 'a'").count
    assert_equal 1, Bar.where("data -> 'a' = 'value5'").count
    assert_equal 9, Bar.where("data -> 'a' <> 'value5'").count
    assert_equal 1, Bar.where("data @> 'a=>value5'").count
    assert_equal 9, Bar.where("not data @> 'a=>value5'").count
    assert_equal 10, Bar.where("data -> 'a' LIKE '%value%'").count
    assert_equal 0, Bar.where("data -> 'a' LIKE '%VALUE%'").count
    assert_equal 10, Bar.where("data -> 'a' ILIKE '%VALUE%'").count
  end

  test "should delete with workaround" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    data = bar.data
    data.delete('a')
    bar.data = data
    bar.save
    bar.reload
    assert_equal({"b"=>"2", "c"=>"3"}, bar.data)
  end
  
  test "should delete in a cool way" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    bar.destroy_key(:data, :a)
    bar.save
    bar.reload
    assert_equal({"b"=>"2", "c"=>"3"}, bar.data)
  end

  test "should delete in a cool way - bang version" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    assert bar.destroy_key!(:data, :a)
    bar.reload
    assert_equal({"b"=>"2", "c"=>"3"}, bar.data)
  end
  
  test "should delete many keys" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    bar.destroy_keys(:data, :a, :b)
    bar.save
    bar.reload
    assert_equal({"c"=>"3"}, bar.data)
  end

  test "should delete many keys - bang version" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    assert bar.destroy_keys!(:data, :a, :b)
    bar.reload
    assert_equal({"c"=>"3"}, bar.data)
  end
  
  test "should delete using method chaining" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    bar.reload
    assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    bar.destroy_key(:data, :a).destroy_key(:data, :b).destroy_key(:data, :c).save
    bar.reload
    assert_equal({}, bar.data)
  end

  test "should delete from the model" do
    bars = Array.new(5){ Bar.create :data => {:a => 1, :b => 2, :c => 3} }
    bars.map(&:reload)
    for bar in bars
      assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    end
    Bar.delete_key(:data, :a)
    bars.map(&:reload)
    for bar in bars
      assert_equal({"b"=>"2", "c"=>"3"}, bar.data)
    end
  end

  test "should delete many keys from the model" do
    bars = Array.new(5){ Bar.create :data => {:a => 1, :b => 2, :c => 3} }
    bars.map(&:reload)
    for bar in bars
      assert_equal({"a"=>"1", "b"=>"2", "c"=>"3"}, bar.data)
    end
    Bar.delete_keys(:data, :a, :b)
    bars.map(&:reload)
    for bar in bars
      assert_equal({"c"=>"3"}, bar.data)
    end
  end

  test "should explode if there is not column trying to delete from the record" do
    bar = Bar.create :data => {:a => 1, :b => 2, :c => 3}
    assert_raise RuntimeError do
      bar.destroy_key(:foo, :a)
    end
  end


  test "should explode if there is not column trying to delete from the model" do
    assert_raise RuntimeError do
      Bar.delete_key(:foo, :a)
    end
  end
end
