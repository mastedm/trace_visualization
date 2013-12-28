require 'trace_visualization'
require 'trace_visualization/suffix_array'
require 'trace_visualization/longest_common_prefix'
require 'trace_visualization/bwt'


describe TraceVisualization::Repetitions do
  it 'simple test PSY1' do
    TraceVisualization::Repetitions.psy1('aaabbbcccaaacccbbb', 3, false).should eq [
        {:lcp=>3, :i=>0, :j=>1}, 
        {:lcp=>3, :i=>8, :j=>9}, 
        {:lcp=>3, :i=>16, :j=>17}
    ]
  end
  
  it 'simple test PSY1 with mapping' do
    str = 'aaa{TOKEN;id;[123];123;1}aaa'

    mapping = TraceVisualization::Mapping.new
    mapping.process { from_string str }
    
    TraceVisualization::Repetitions.psy1(mapping, 3, false).should eq [{:lcp=>3, :i=>2, :j=>3}]
  end
  
  it 'test decode PSY1' do
    # <---> "aaaXxyzYaaaX"
    str = "aaa{TOKEN;id;[123];123;1}xyz{TOKEN;id;[654];654;1}aaa{TOKEN;id;[123];123;1}" 

    mapping = TraceVisualization::Mapping.new
    mapping.process { from_string str }
    
    rs = TraceVisualization::Repetitions.psy1(mapping, 3)
    
    rs.size.should eq 1
    rs[0].length.should eq 4
    rs[0].left_positions.should eq [0, 8]
    
    length   = rs[0].length
    position = rs[0].left_positions[0]

    mapping.restore(position, length).should eq "aaa[123]"
  end
end
