require 'trace_visualization'
require 'trace_visualization/algorithm'

include TraceVisualization

describe Algorithm do
  it 'smoke' do
    mapping = Mapping.new
    mapping.process { from_preprocessed_string "test1\ntest2\ntest3\ntest4" }

    repetitions = Algorithm.process(mapping, {})
    
    for repetition in repetitions do
      puts repetition
      puts Visualization::ConsoleColorPrint.hl(mapping, repetitions[0])
    end
    
    # Filter repetitions!
    
    # RepetitionsScore.fill_score(repetitions, :sort => true, :order => 'desc', :version => 'relative')
    # 
    # puts Visualization::ConsoleColorPrint.hl(mapping, repetitions[0])
  end
end
