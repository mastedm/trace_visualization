require 'trace_visualization/repetitions/concatenation'
require 'trace_visualization/repetitions/context'
require 'trace_visualization/data/repetition'

include TraceVisualization
include TraceVisualization::Data
include TraceVisualization::Repetitions

describe Concatenation do
  it "process common positions" do
    str = "aaaxbbbyaaazbbbvaaawbbb"

    mapping = TraceVisualization::Mapping.new
    mapping.process { from_string(str) }

    context = Context.new(mapping)
    
    lpos = [0, 8, 16]
    rpos = [4, 12, 20]
    ppos = [[0, 4], [8, 12], [16, 20]]
    
    left  = Repetition.new(3, lpos)
    right = Repetition.new(3, rpos)
    
    cpl, cpr = Concatenation.process_common_positions(left, right, 1, context)

    left.left_positions.should  eq cpl
    right.left_positions.should eq cpr

    lpos.should eq left.left_positions
    rpos.should eq right.left_positions
  end
  
  it "don't concatenate repetitions through forbidden chars" do
    str = <<EOF
aaa
bbb
aaa
bbb
EOF
    context = Context.new(str)
      
    lpos, rpos = [0, 8], [4, 12]
    left  = Repetition.new(3, lpos)
    right = Repetition.new(3, rpos)      
    
    cpl, cpr = Concatenation.process_common_positions(left, right, 1, context)
      
    cpl.should eq []
    cpr.should eq []
    
    #
    str.gsub!(TraceVisualization::FORBIDDEN_CHARS, "x")
    context = Context.new(str)
      
    lpos, rpos = [0, 8], [4, 12]
    left  = Repetition.new(3, lpos)
    right = Repetition.new(3, rpos)      
    
    cpl, cpr = Concatenation.process_common_positions(left, right, 1, context)
    
    cpl.should eq [0, 8]
    cpr.should eq [4, 12]    
  end
end
