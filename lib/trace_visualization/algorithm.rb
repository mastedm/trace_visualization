require 'trace_visualization/utils'
require 'trace_visualization/assert'
require 'trace_visualization/repetitions/concatenation'

module TraceVisualization
  
  # Main algorithm
  module Algorithm
    include TraceVisualization
    
    # Run main algorithm of approximate repeats processing
    # @param mapping [TraceVisualization::Mapping] 
    # @param options [Hash]
    def self.process(mapping, options = {})
      TraceVisualization.assert_instance_of(mapping, Mapping)
      
      Utils.set_default_options(options, { :positions_min_size => 3 })

      # First step - calculate strict repetitions
      repetitions = Repetitions.psy1(mapping, options[:positions_min_size])
      
      context = Repetitions::Context.new(mapping, repetitions)
      
      # Second step - iterative process concatenation & incrementation algorithms for approximate repeats processing
      Repetitions::Concatenation.process(repetitions, 1, context, { :positions_min_size => options[:positions_min_size] })
      
      repetitions
    end
    
  end # Algorithm
end # TraceVisualization