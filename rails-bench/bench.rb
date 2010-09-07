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
  x.report("create with serialize") {
    1000.times do 
      Foo.create :data => {:foo => STR, :bar => 123, :baz => :yo}
    end
  }
  x.report("create with hstore") {
    1000.times do 
      Bar.create :data => {:foo => STR, :bar => 123, :baz => :yo}
    end
  }
end
puts result.inspect
