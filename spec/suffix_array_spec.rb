require 'trace_visualization/suffix_array'
require 'trace_visualization/mapping'

describe TraceVisualization::SuffixArray do
  
  context ".naive" do
    it "should return suffix array" do
      TraceVisualization::SuffixArray.naive("abaabaab").should eq([5, 2, 6, 3, 0, 7, 4, 1])
      TraceVisualization::SuffixArray.naive("abracadabra").should eq([10, 7, 0, 3, 5, 8, 1, 4, 6, 9, 2])
    end
    
    it "should correct process mapped string" do
      str = "abc[123]def[456]ghi"
      mapped_str = TraceVisualization::Mapping.new(str)
      
      TraceVisualization::SuffixArray.naive(mapped_str).should eq([0, 1, 2, 4, 5, 6, 8, 9, 10, 3, 7])
    end
  end
  
  context ".radix_pass" do
    it "do stable radix sort" do
  		str = [3, 3, 2, 1, 5, 5, 4]
  		a = [0, 1, 2, 3, 4, 5, 6]
      n = a.length
  		b = Array.new(n)
		
      TraceVisualization::SuffixArray.radix_pass(a, b, str, n, 10)
    
      b.should eq([3, 2, 0, 1, 6, 4, 5])
    end
  end
  
  context ".effective_linear" do
    it "should return suffix array for linear time (native function)" do
  		s = [3, 3, 2, 1, 5, 5, 4, 0, 0, 0]
  		n = s.length - 3 # exclude last 3 zeros
  		alphabet_size = 10
      suffix_array = Array.new(n + 3, 0)
			
  		TraceVisualization::SuffixArray.effective_linear(s, suffix_array, n, alphabet_size)
			
      suffix_array.should eq([3, 2, 1, 0, 6, 5, 4, 0, 0, 0])
    end
  end
  
  context ".effective" do 
    it "should return suffix array for linear time (wrapper function)" do
      TraceVisualization::SuffixArray.effective("abaabaab").should eq(TraceVisualization::SuffixArray.naive("abaabaab"))
      TraceVisualization::SuffixArray.effective("abracadabra").should eq(TraceVisualization::SuffixArray.naive("abracadabra"))      
    end
    
    it "should correct process mapped string" do
      str = "abc[123]def[456]ghi"
      mapped_str = TraceVisualization::Mapping.new(str)
      
      TraceVisualization::SuffixArray.effective(mapped_str).should eq([0, 1, 2, 4, 5, 6, 8, 9, 10, 3, 7])
    end
    
    it "another string for mapped processing" do
      str = "127.0.0.1 a 127.0.0.1 b"
      
      # 'X a X b'
      mapped_str = TraceVisualization::Mapping.new(str)
      
      mapped_str[0].to_int.should eq 4
      mapped_str[1].to_int.should eq 1
      mapped_str[2].to_int.should eq 2
      mapped_str[3].to_int.should eq 1
      mapped_str[4].to_int.should eq 4
      mapped_str[5].to_int.should eq 1
      mapped_str[6].to_int.should eq 3      

      length_before = mapped_str.length
      
      sa = TraceVisualization::SuffixArray.effective(mapped_str)
      mapped_str.length.should be length_before

      sa.should eq [1, 5, 3, 2, 6, 0, 4]
      sa.length.should be mapped_str.length
    end
    
    it "bug with endless loop" do
      str = "127.0.0.1 user login\r\n127.0.0.1 user logout"
      mapped_str = TraceVisualization::Mapping.new(str)
      
      sa = TraceVisualization::SuffixArray.effective(mapped_str)      
    end    
  end
  
end
