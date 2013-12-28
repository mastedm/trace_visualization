require 'trace_visualization/repetitions/incrementation'
require 'trace_visualization/repetitions/context'
require 'trace_visualization/repetitions/filter'
require 'trace_visualization/data/repetition'
require 'trace_visualization/visualization/console_color_print'

include TraceVisualization
include TraceVisualization::Data
include TraceVisualization::Repetitions
include TraceVisualization::Visualization 

describe Incrementation do
  it 'smoke test' do
    str = "testA\ntestB\ntestC\ntestA\ntestB"
    
    mapping = TraceVisualization::Mapping.new
    mapping.process { from_string(str) }

    context = Context.new(mapping)
    
    context.repetitions = TraceVisualization::Repetitions.psy1(mapping, 2)

    Filter.strict_repetitions_filter(mapping, context, { :positions_min_size => 2 })
    
    Incrementation.process(context, { :positions_min_size => 2, :k => 1 })
    
    ConsoleColorPrint.hl_stdout(mapping, context.repetitions)
  end
end