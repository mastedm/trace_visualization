require 'travis/data/repetition'

module Travis
  module Visualization
    module ConsoleColorPrint
      
      GRN  = "\033[1;32m"
      YLW  = "\033[1;33m"
      FNSH = "\033[0m"
      
      def self.hl(str, repetition)
        result = ""
        prev_position = 0
        positions = repetition.build_positions
    
        positions.each do |position|
          result += str[prev_position ... position[0][0]]
      
          for i in 0 ... position.size
            pos, len = position[i]
            result += GRN + "#{str[pos ... pos + len]}" + FNSH
            result += YLW + "#{str[pos + len ... position[i + 1][0]]}" + FNSH if i < position.size - 1
          end
      
          prev_position = position[-1][0] + position[-1][1]
        end
    
        result += str[prev_position .. -1]
      end
    end
  end
end