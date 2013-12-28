require 'trace_visualization/suffix_array'
require 'trace_visualization/mapping'

describe TraceVisualization::SuffixArray do
  
  context '.naive' do
    it 'should return suffix array' do
      TraceVisualization::SuffixArray.naive('abaabaab').should eq([5, 2, 6, 3, 0, 7, 4, 1])
      TraceVisualization::SuffixArray.naive('abracadabra').should eq([10, 7, 0, 3, 5, 8, 1, 4, 6, 9, 2])
    end
    
    it 'should correct process mapped string' do
      str = 'abc{TOKEN;id;[123];123;1}def{TOKEN;id;[456];456;1}ghi'

      mapping = TraceVisualization::Mapping.new
      mapping.process { from_string(str) }
      
      TraceVisualization::SuffixArray.naive(mapping).should eq([0, 1, 2, 4, 5, 6, 8, 9, 10, 3, 7])
    end
  end
  
  context '.radix_pass' do
    it 'do stable radix sort' do
  		str = [3, 3, 2, 1, 5, 5, 4]
  		a = [0, 1, 2, 3, 4, 5, 6]
      n = a.length
  		b = Array.new(n)
		
      TraceVisualization::SuffixArray.radix_pass(a, b, str, n, 10)
    
      b.should eq([3, 2, 0, 1, 6, 4, 5])
    end
  end
  
  context '.effective_linear' do
    it 'should return suffix array for linear time (native function)' do
  		s = [3, 3, 2, 1, 5, 5, 4, 0, 0, 0]
  		n = s.length - 3 # exclude last 3 zeros
  		alphabet_size = 10
      suffix_array = Array.new(n + 3, 0)
			
  		TraceVisualization::SuffixArray.effective_linear(s, suffix_array, n, alphabet_size)
			
      suffix_array.should eq([3, 2, 1, 0, 6, 5, 4, 0, 0, 0])
    end
  end
  
  context '.effective' do
    it 'should return suffix array for linear time (wrapper function)' do
      TraceVisualization::SuffixArray.effective('abaabaab').should eq(TraceVisualization::SuffixArray.naive('abaabaab'))
      TraceVisualization::SuffixArray.effective('abracadabra').should eq(TraceVisualization::SuffixArray.naive('abracadabra'))
    end
    
    it 'should correct process mapped string' do
      str = 'abc{TOKEN;id;[123];123;1}def{TOKEN;id;[456];456;1}ghi'

      mapping = TraceVisualization::Mapping.new
      mapping.process { from_string(str) }
      
      TraceVisualization::SuffixArray.effective(mapping).should eq([0, 1, 2, 4, 5, 6, 8, 9, 10, 3, 7])
    end
    
    it 'another string for mapped processing' do
      str = "{TOKEN;ip;127.0.0.1;1000;1} a {TOKEN;ip;127.0.0.1;1000;1} b"
      
      # 'X a X b'
      mapping = TraceVisualization::Mapping.new
      mapping.process { from_string(str) }

      mapping[0].to_int.should eq 4
      mapping[1].to_int.should eq 1
      mapping[2].to_int.should eq 2
      mapping[3].to_int.should eq 1
      mapping[4].to_int.should eq 4
      mapping[5].to_int.should eq 1
      mapping[6].to_int.should eq 3

      length_before = mapping.length
      
      sa = TraceVisualization::SuffixArray.effective(mapping)
      mapping.length.should be length_before

      sa.should eq [1, 5, 3, 2, 6, 0, 4]
      sa.length.should be mapping.length
    end
    
    it 'bug with endless loop' do
      str = "127.0.0.1 user login\r\n127.0.0.1 user logout"

      mapping = TraceVisualization::Mapping.new
      mapping.process { from_string str }
      
      sa = TraceVisualization::SuffixArray.effective(mapping)
    end    
  end
  
end
