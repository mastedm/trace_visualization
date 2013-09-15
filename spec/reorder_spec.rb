require 'trace_visualization'
require 'trace_visualization/reorder'

describe TraceVisualization::Reorder do

  class A
    include Comparable
    
    attr_accessor :ord
    attr_accessor :int_value
    
    def initialize(theValue)
      @int_value = theValue
    end
    
    def <=>(anOther)
      @ord <=> anOther.ord
    end
    
  end

  it "reorder values and set correct order" do
    data = Array.new(100) { |index| A.new(index * 100) }
    data.shuffle!
    
    max_value = TraceVisualization::Reorder.process(data)
    
    data.each { |item| item.ord.should eq(item.int_value / 100 + 1) }
    max_value.should eq 100
  end
  
  it "duplicate values with the same order" do
    x1, x2 = A.new(1), A.new(2)
    x3, x4 = A.new(123456789), A.new(123456789)

    data = [x1, x2, x3, x4].shuffle
    
    max_value = TraceVisualization::Reorder.process(data)
    
    x1.ord.should eq(1)
    x2.ord.should eq(2)
    x3.ord.should eq(3)    
    x4.ord.should eq(3)
    
    max_value.should eq 3
  end
  
  it "test TERMINATION_CHAR" do
    x1 = A.new(2**7)
    x2 = A.new(2**9)
    x3 = A.new(TraceVisualization::TERMINATION_CHAR.ord)
    
    data = [x1, x2, x3].shuffle
    max_value = TraceVisualization::Reorder.process(data)
   
    (x1 < x2).should be_true
    (x2 < x3).should be_true
    max_value.should eq x3.ord
  end
end
