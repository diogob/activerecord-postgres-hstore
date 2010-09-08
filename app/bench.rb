STR = <<-STR
The Benchmark  module provides methods to measure  and report the time used to execute Ruby code.

    * Measure the time to construct the string given by the expression "a"*1_000_000:

          require 'benchmark'

          puts Benchmark.measure { "a"*1_000_000 }

      On my machine (FreeBSD 3.2 on P5, 100MHz) this generates:

          1.166667   0.050000   1.216667 (  0.571355)

      This report shows the user CPU time, system CPU time, the sum of the user and system CPU times, and the elapsed real time. The unit of time is seconds.
STR

require 'benchmark'
result = Benchmark.bm do |x|
  Foo.delete_all
  Bar.delete_all
  puts "Foo (#{Foo.count})"
  puts "Bar (#{Bar.count})"
  x.report("create with serialize") do
    1000.times do |i|
      Foo.create :data => {:foo => STR, :bar => i, :baz => :yo}
    end
  end
  x.report("create with hstore") {
    1000.times do |i|
      Bar.create :data => {:foo => STR, :bar => i, :baz => :yo}
    end
  }

  x.report("update with serialize") {
    1000.times do |i|
      foo = Foo.create
      foo.update_attribute :data, {:foo => STR, :bar => i, :baz => :yo}
    end
  }
  x.report("update with hstore") {
    1000.times do |i|
      bar = Bar.create
      bar.update_attribute :data, {:foo => STR, :bar => i, :baz => :yo}
    end
  }

  x.report("select with serialize"){
    1000.times do |i|
      foo = Foo.create :data => {:foo => 'bar'}
      Foo.where("data ~ 'foo: bar'")
    end
  }
  x.report("select with hstore"){
    1000.times do |i|
      bar = Bar.create :data => {:foo => 'bar'}
      Bar.where("data -> 'foo' = 'bar'")
    end
  }
  Foo.delete_all
  Bar.delete_all
  puts "Foo (#{Foo.count})"
  puts "Bar (#{Bar.count})"
  x.report("copy serialize"){ Foo.connection.execute "COPY foos (data) FROM '#{Rails.root}/foos.copy'" }
  x.report("copy hstore"){ Bar.connection.execute "COPY bars (data) FROM '#{Rails.root}/bars.copy'" }
  x.report("select one in a million rows - serialize"){
    1000.times do |i|
      Foo.first(:conditions => "data ~ 'foo: bar'", :order => 'id desc')
    end
  }
  x.report("select one in a million rows - hstore"){
    1000.times do |i|
      Bar.first(:conditions => "data -> 'foo' = 'bar'", :order => 'id desc')
    end
  }
end
puts result.inspect
