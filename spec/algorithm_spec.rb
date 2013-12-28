require 'trace_visualization'
require 'trace_visualization/algorithm'
require 'trace_visualization/visualization/console_color_print'

include TraceVisualization

describe Algorithm do
  it 'smoke' do
    mapping = Mapping.new
    mapping.process { from_string "test1\ntest2\ntest3\ntest4" }

    repetitions = Algorithm.process(mapping, {})
    
    repetitions.size.should eq 1
    
    repetition = repetitions[0]
    repetition.k.should eq 0
    repetition.length.should eq 4
    repetition.left_positions.size.should eq 4
    repetition.left.should be_nil
    repetition.right.should be_nil
  end

  it 'two strict repetitions with k = 1' do
    mapping = Mapping.new
    mapping.process { from_string "fooAbar\nfooBbar\nfooCbar" }
    
    repetitions = Algorithm.process(mapping, {})
    
    repetitions.size.should eq 3
    repetitions[0].k.should eq 0
    repetitions[1].k.should eq 0
    repetitions[2].k.should eq 1
    
    repetitions[0].length.should eq 3
    repetitions[1].length.should eq 3
    repetitions[2].length.should eq 7
  end

  it 'two strict repetitions with k = 2' do
    mapping = Mapping.new
    mapping.process { from_string "fooABbar\nfooCDbar\nfooEFbar" }
    
    repetitions = Algorithm.process(mapping, {})
    
    repetitions.size.should eq 3
    repetitions[0].k.should eq 0
    repetitions[1].k.should eq 0
    repetitions[2].k.should eq 2
    
    repetitions[0].length.should eq 3
    repetitions[1].length.should eq 3
    repetitions[2].length.should eq 8
  end
  
  it 'one strict repetition - self-concatenation' do
    mapping = Mapping.new
    mapping.process { from_string "testAtest\ntestBtest\ntestCtest" }
    
    repetitions = Algorithm.process(mapping, {})
    
    # for repetition in repetitions
    #   puts "* * * * * * * * * *"
    #   puts "k = #{repetition.k}, length = #{repetition.length}, positions.size = #{repetition.left_positions.size}"
    #   puts Visualization::ConsoleColorPrint.hl(mapping, repetition)
    #   puts "* * * * * * * * * *"      
    # end
  end
end
