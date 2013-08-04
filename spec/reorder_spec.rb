require 'trace_visualization/reorder'

describe TraceVisualization::Reorder do

  class A
    include Comparable
    
    attr_accessor :ord
    attr_accessor :value
    
    def initialize(theValue)
      @value = theValue
    end
    
    def <=>(anOther)
      @value <=> anOther.value
    end
  end

  it "reorder values and set correct order" do
    data = Array.new(100) { |index| A.new(index * 100) }
    data.shuffle!
    
    TraceVisualization::Reorder.process(data)
    
    data.each { |item| item.ord.should eq(item.value / 100 + 1) }
  end
  
  it "duplicate values with the same order", :current => true do
    x1, x2 = A.new(1), A.new(2)
    x3, x4 = A.new(123456789), A.new(123456789)

    data = [x1, x2, x3, x4].shuffle
    
    TraceVisualization::Reorder.process(data)
    
    x1.ord.should eq(1)
    x2.ord.should eq(2)
    x3.ord.should eq(3)    
    x4.ord.should eq(3)
  end
end
