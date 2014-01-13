require 'trace_visualization/data/repetition'

module TraceVisualization
  module Visualization
    module ConsoleColorPrint
      
      GRN  = "\033[1;32m"
      YLW  = "\033[1;33m"
      FINISH = "\033[0m"
      
      def self.hl(mapping, repetition)
        if not repetition.instance_of? TraceVisualization::Data::Repetition
          raise "repetition must be instance of TraceVisualization::Data::Repetition, actually - #{repetition.class}"
        end
        
        result = ''
        prev_position = 0
        positions = repetition.build_positions
    
        positions.each do |position|
          result += mapping.restore(prev_position, position[0][0] - prev_position)
      
          for i in 0 ... position.size
            pos, len = position[i]
            result += GRN + "#{mapping.restore(pos, len)}" + FINISH
            result += YLW + "#{mapping.restore(pos + len, position[i + 1][0] - (pos + len))}" + FINISH if i < position.size - 1
          end
      
          prev_position = position[-1][0] + position[-1][1]
        end
    
        result += mapping.restore(prev_position, mapping.length - prev_position)
      end
      
      def self.hl_stdout(mapping, repetition)
        if repetition.instance_of? Array
          puts "* * * S T A R T * * *"
          for r in repetition
            puts r
            puts hl(mapping, r)
            puts "- - - - - - - - - - -"
          end
        else
          puts "* * * S T A R T * * *"
          puts repetition
          puts hl(mapping, repetition)
          puts "- - - - - - - - - - -"          
        end
      end
      
      def self.print_tree(repetition, indent = 0)
        puts "#{'-' * 4 * indent}> id = #{repetition.id}, k = #{repetition.k}, length = #{repetition.length}"
        print_tree(repetition.left,  indent + 1) if repetition.left
        print_tree(repetition.right, indent + 1) if repetition.right
      end
    end
  end
end