require 'trace_visualization/repetitions_concatenation'
require 'trace_visualization/repetitions_context'
require 'trace_visualization/data/repetition'

describe TraceVisualization::RepetitionsConcatenation do
  it "process common positions" do
    str = "aaaxbbbyaaazbbbvaaawbbb"

    mapping = TraceVisualization::Mapping.init do
      default_tokens
    end

    mapping.process { from_string(str) }

    context = TraceVisualization::Repetitions::Context.new(mapping, [])
    
    lpos = [0, 8, 16]
    rpos = [4, 12, 20]
    ppos = [[0, 4], [8, 12], [16, 20]]
    
    left  = TraceVisualization::Data::Repetition.new(3, lpos)
    right = TraceVisualization::Data::Repetition.new(3, rpos)
    
    cpl, cpr = TraceVisualization::RepetitionsConcatenation.process_common_positions(left, right, 1, context)

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
    context = TraceVisualization::Repetitions::Context.new(str, [])
      
    lpos, rpos = [0, 8], [4, 12]
    left  = TraceVisualization::Data::Repetition.new(3, lpos)
    right = TraceVisualization::Data::Repetition.new(3, rpos)      
    
    cpl, cpr = TraceVisualization::RepetitionsConcatenation.process_common_positions(left, right, 1, context)
      
    cpl.should eq []
    cpr.should eq []
    
    #
    str.gsub!(TraceVisualization::FORBIDDEN_CHARS, "x")
    context = TraceVisualization::Repetitions::Context.new(str, [])
      
    lpos, rpos = [0, 8], [4, 12]
    left  = TraceVisualization::Data::Repetition.new(3, lpos)
    right = TraceVisualization::Data::Repetition.new(3, rpos)      
    
    cpl, cpr = TraceVisualization::RepetitionsConcatenation.process_common_positions(left, right, 1, context)
    
    cpl.should eq [0, 8]
    cpr.should eq [4, 12]    
  end
end
