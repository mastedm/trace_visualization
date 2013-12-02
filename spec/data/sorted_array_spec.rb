require 'trace_visualization'
require 'trace_visualization/data/sorted_array'

include TraceVisualization
include TraceVisualization::Data

describe SortedArray do
  it 'should correct insert values' do
    a = SortedArray.new([4, 5, 1, 2])
    a << 3
    a.push 6
    a << 0
    a.should eq [0, 1, 2, 3, 4, 5, 6]
  end
  
  it 'should correct index value' do
    a = SortedArray.new([1, 4, 5, 4, 1, 2, 5])
    a.should eq [1, 1, 2, 4, 4, 5, 5]
    a.index(1).should eq 0
    a.index(2).should eq 2
    a.index(4).should eq 3
    a.index(5).should eq 5
    a.index(0).should eq nil
    a.index(3).should eq nil
    a.index(6).should eq nil    
  end
end