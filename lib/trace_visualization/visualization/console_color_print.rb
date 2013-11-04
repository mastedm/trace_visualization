require 'trace_visualization/data/repetition'

module TraceVisualization
  module Visualization
    module ConsoleColorPrint
      
      GRN  = "\033[1;32m"
      YLW  = "\033[1;33m"
      FINISH = "\033[0m"
      
      def self.hl(mapping, repetition)
        raise 'repetition must be instance of TraceVisualization::Data::Repetition' if not repetition.instance_of? TraceVisualization::Data::Repetition
        
        result = ''
        prev_position = 0
        positions = repetition.build_positions
    
        positions.each do |position|
          result += mapping.restore(prev_position, position[0][0])
      
          for i in 0 ... position.size
            pos, len = position[i]
            result += GRN + "#{mapping.restore(pos, pos + len)}" + FINISH
            result += YLW + "#{mapping.restore(pos + len, position[i + 1][0])}" + FINISH if i < position.size - 1
          end
      
          prev_position = position[-1][0] + position[-1][1]
        end
    
        result += mapping.restore(prev_position, -1)
      end
    end
  end
end