require 'trace_visualization'
require 'trace_visualization/mapping'
require 'trace_visualization/repetitions/filter'
require 'trace_visualization/data/repetition'

include TraceVisualization
include TraceVisualization::Data
include TraceVisualization::Repetitions

describe Filter do
  it 'test fix_boundaries' do
    str = "test\ntest\ntest\n"

    rs = [ 
      Repetition.new(5, [0, 5, 10]), # "test\n"
      Repetition.new(6, [4, 9]),     # "\ntest\n"
      Repetition.new(9, [0, 5])      # "test\ntest"      
    ]
    
    Filter.fix_boundaries(str, rs)
    
    rs[0].length.should eq 4
    rs[0].left_positions.should eq [0, 5, 10]
    
    rs[1].length.should eq 4
    rs[1].left_positions.should eq [5, 10]
    
    rs[2].length.should eq 9
    rs[2].left_positions.should eq [0, 5]    
  end  

  it 'test split' do
    mapping = Mapping.new
    mapping.process { from_preprocessed_string "test\ntest\ntest\n" }

    repetitions = [ 
      Repetition.new(5, [0, 5, 10]), # "test\n"
      Repetition.new(6, [4, 9]),     # "\ntest\n"
      Repetition.new(9, [0, 5])      # "test\ntest"      
    ]
      
    context = Context.new(mapping, repetitions)
    Filter.split(mapping, repetitions, context)
    
    rsplitted_1 = Repetition.new(4, [0, 5])
    rsplitted_2 = Repetition.new(4, [5, 10])
    
    repetitions.size.should eq 4
    
    (
      (repetitions[2] == rsplitted_1 && repetitions[3] == rsplitted_2) || 
      (repetitions[3] == rsplitted_1 && repetitions[2] == rsplitted_2)
    ).should be_true
    
    ####

    # Delete subrepetition after split  
    repetitions = [ 
      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(9, [0, 5])      # "test\ntest"      
    ]
      
    context = Context.new(mapping, repetitions)

    Filter.split(mapping, repetitions, context)
    
    repetitions.size.should eq 1
    
    (repetitions[0] == Repetition.new(4, [0, 5, 10])).should be_true
  end
  
  it 'test for delete_duplicates' do
    mapping = Mapping.new
    mapping.process { from_preprocessed_string "test\ntest\ntest\n" }

    repetitions = [ 
      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(6, [4, 9]),     # "\ntest\n"

      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(6, [4, 9]),     # "\ntest\n"

      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(6, [4, 9])      # "\ntest\n"      
    ]
      
    context = Context.new(mapping, repetitions)
    Filter.delete_duplicates(repetitions, context)
    
    repetitions.size.should eq 2
    (
      repetitions[0] == Repetition.new(4, [0, 5, 10]) && 
      repetitions[1] == Repetition.new(6, [4, 9])
    ).should be_true
  end
  
  it 'test for repetitions merge' do
    mapping = Mapping.new
    mapping.process { from_preprocessed_string "test\ntest\ntest\n" }
    
    repetitions = [
      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(4, [0, 5]),     # "test"
      Repetition.new(4, [5, 10]),    # "test"
    ]
    
    context = Context.new(mapping, repetitions)
    Filter.merge(repetitions, context)
    
    repetitions.size.should eq 1
    (repetitions[0] == Repetition.new(4, [0, 5, 10])).should be_true
    repetitions[0].lines.should eq [0, 1, 2]
        
    # Different order of repetitions and positions
    repetitions = [
      Repetition.new(4, [0, 10]),    # "test"
      Repetition.new(4, [0, 5, 10]), # "test"
      Repetition.new(4, [5, 10]),    # "test"
    ]
    
    context = Context.new(mapping, repetitions)

    Filter.merge(repetitions, context)
    
    repetitions.size.should eq 1
    (repetitions[0] == Repetition.new(4, [0, 5, 10])).should be_true
    repetitions[0].lines.should eq [0, 1, 2]
  end
end