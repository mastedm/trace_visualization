require 'trace_visualization/longest_common_prefix'
require 'trace_visualization/suffix_array'
require 'trace_visualization/mapping'

describe TraceVisualization::LongestCommonPrefix do
  
  context '.effective' do
    it 'should return array with longest common prefix in linear time' do
  		str = 'mississippi'
      
      sa = TraceVisualization::SuffixArray.effective(str)
      lcp = TraceVisualization::LongestCommonPrefix.effective(str, sa, str.size)
      
      lcp.should eq([0, 1, 1, 4, 0, 0, 1, 0, 2, 1, 3])
    end
    
    it 'should return correct result for mapped string', :current => true do
      str = "{TOKEN;ip;127.0.0.1;1000;1} foo\r\n{TOKEN;ip;127.0.0.1;1000;1} bar"

      mapping = TraceVisualization::Mapping.new
      mapping.process { from_string(str) }
      
      sa = TraceVisualization::SuffixArray.effective(mapping)
      lcp = TraceVisualization::LongestCommonPrefix.effective(mapping, sa, mapping.length)

      sa.should eq([6, 5, 8, 1, 10, 9, 2, 4, 3, 11, 7, 0])
      lcp.should eq([0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 2])
    end
  end
  
end
