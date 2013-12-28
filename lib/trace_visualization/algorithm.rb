require 'trace_visualization/utils'
require 'trace_visualization/assert'
require 'trace_visualization/repetitions/filter'
require 'trace_visualization/repetitions/concatenation'

module TraceVisualization
  
  # Main algorithm
  module Algorithm
    include TraceVisualization
    include TraceVisualization::Repetitions    
    
    # Run main algorithm of approximate repeats processing
    # @param mapping [TraceVisualization::Mapping] 
    # @param options [Hash]
    def self.process(mapping, options = {})
      TraceVisualization.assert_instance_of(mapping, Mapping)
      
      Utils.set_default_options(options, { :positions_min_size => 3, :k => 3 })

      context = Context.new(mapping)

      # First step - calculate strict repetitions
      context.repetitions = Repetitions.psy1(mapping, options[:positions_min_size])
      
      # Second step - iterative process concatenation & incrementation algorithms for approximate repeats processing
      Filter.strict_repetitions_filter(mapping, context, options)
      
      for kk in 1 .. options[:k]
        Concatenation.process(context, { 
          :k => kk,
          :positions_min_size => options[:positions_min_size]
        })
        
        Filter.repetitions_filter(mapping, context, options)
      end
      
      context.repetitions
    end
    
  end # Algorithm
end # TraceVisualization