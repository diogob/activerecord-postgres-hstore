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

  test "should delete" do
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
end
