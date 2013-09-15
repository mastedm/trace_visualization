require 'trace_visualization/longest_common_prefix'
require 'trace_visualization/suffix_array'
require 'trace_visualization/mapping'

describe TraceVisualization::LongestCommonPrefix do
  
  context '.effective' do
    it 'should return array with longest common prefix in linear time' do
  		str = "mississippi"
      
      sa = TraceVisualization::SuffixArray.effective(str)
      lcp = TraceVisualization::LongestCommonPrefix.effective(str, sa, str.size)
      
      lcp.should eq([0, 1, 1, 4, 0, 0, 1, 0, 2, 1, 3])
    end
    
    it 'should return correct result for mapped string', :current => true do
      str = "127.0.0.1 foo\r\n127.0.0.1 bar"
      mapped_str = TraceVisualization::Mapping.new(str)
      
      sa = TraceVisualization::SuffixArray.effective(mapped_str)
      lcp = TraceVisualization::LongestCommonPrefix.effective(mapped_str, sa, mapped_str.length)

      sa.should eq([6, 5, 8, 1, 10, 9, 2, 4, 3, 11, 7, 0])
      lcp.should eq([0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 2])
    end
  end
  
end
