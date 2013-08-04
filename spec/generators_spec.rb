require 'trace_visualization/generators'

describe TraceVisualization::Generators do
  describe TraceVisualization::Generators::Thue do
    it "thue_2_3" do
      TraceVisualization::Generators::Thue.str_2_3(0).should eq "a"
      TraceVisualization::Generators::Thue.str_2_3(1).should eq "ab"
      TraceVisualization::Generators::Thue.str_2_3(2).should eq "abba"
      TraceVisualization::Generators::Thue.str_2_3(3).should eq "abbabaab"
      TraceVisualization::Generators::Thue.str_2_3(4).should eq "abbabaabbaababba"
      TraceVisualization::Generators::Thue.str_2_3(5).should eq "abbabaabbaababbabaababbaabbabaab"
    end
    
    it "thue_3_2" do
      TraceVisualization::Generators::Thue.str_3_2(0).should eq "a"
      TraceVisualization::Generators::Thue.str_3_2(1).should eq "abcab"
      TraceVisualization::Generators::Thue.str_3_2(2).should eq "abcabacabcbacbcacbabcabacabcb"
    end
    
    it "fibonacci" do
      TraceVisualization::Generators::Fibonacci.str(0).should eq "b"
      TraceVisualization::Generators::Fibonacci.str(1).should eq "a"
      TraceVisualization::Generators::Fibonacci.str(2).should eq "ab"
      TraceVisualization::Generators::Fibonacci.str(3).should eq "aba"
      TraceVisualization::Generators::Fibonacci.str(4).should eq "abaab"
      TraceVisualization::Generators::Fibonacci.str(5).should eq "abaababa"
      TraceVisualization::Generators::Fibonacci.str(6).should eq "abaababaabaab"
    end
  end
end
