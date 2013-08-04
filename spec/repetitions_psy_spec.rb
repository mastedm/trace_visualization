require 'trace_visualization'
require 'trace_visualization/repetitions_psy'
require 'trace_visualization/suffix_array'
require 'trace_visualization/longest_common_prefix'
require 'trace_visualization/bwt'
require 'trace_visualization/mapping'

describe TraceVisualization::Repetitions do
  it 'simple test PSY1' do
    TraceVisualization::Repetitions.psy1("aaabbbcccaaacccbbb", 3, false).should eq [
        {:lcp=>3, :i=>0, :j=>1}, 
        {:lcp=>3, :i=>8, :j=>9}, 
        {:lcp=>3, :i=>16, :j=>17}
    ]
  end
  
  it 'simple test PSY1 with mapping' do
    str = "aaa[123]aaa"
    arr = TraceVisualization::Mapping.parse(str)
    
    TraceVisualization::Repetitions.psy1(arr, 3, false).should eq [{:lcp=>3, :i=>2, :j=>3}]
  end
  
  it 'test decode PSY1' do
    str = "aaa[123]xyz[654]aaa[123]" # <---> "aaaXxyzYaaaX"
    arr = TraceVisualization::Mapping.parse(str)
    
    rs = TraceVisualization::Repetitions.psy1(arr, 3)
    
    rs.size.should eq 1
    rs[0].length.should eq 4
    rs[0].left_positions.should eq [0, 8]
    
    length   = rs[0].length
    position = rs[0].left_positions[0]
    
    TraceVisualization::Mapping.restore(arr[position ... position + length]).should eq "aaa[123]"    
  end
end
