require 'trace_visualization/utils'

module TraceVisualization
  module Repetitions
    class Context
      attr_accessor :mapping, :repetitions, :repetitions_by_line, :hashes
      
      def initialize mapping
        @mapping = mapping
        @repetitions_by_line = Array.new(@mapping.lines.size) { [] }
        @hashes = []
      end
      
      def repetitions=(repetitions)
        @repetitions = repetitions
        init_repetitions_by_line(repetitions)
      end
      
      def lines
        @mapping.lines
      end
      
      def init_repetitions_by_line(new_repetitions)
        for r in new_repetitions
          r_pos = r.left_positions
          r.lines.clear
          i, j = 0, 0
      
          while (i < @mapping.lines.size && j < r_pos.size)
            a, b = @mapping.lines[i], (i + 1 < @mapping.lines.size ? @mapping.lines[i + 1] : 2**32)
        
            if a <= r_pos[j] && r_pos[j] < b
              @repetitions_by_line[i] << [r, r_pos[j]]
              r.lines << i
          
              j += 1
            else
              i += 1
            end        
          end
        end

        @repetitions_by_line.each { |item| item.sort! { |a, b| a[1] <=> b[1] } }
      end
      
      def delete_repetition(repetition)
        repetition.lines.each do |line|
          @repetitions_by_line[line].delete_if { |item| item[0].id == repetition.id }
        end
      end
      
      def merge_repetitions(x, y)
        x.left_positions.concat(y.left_positions).uniq!.sort!
        
        if x.right_positions
          x.right_positions.concat(y.right_positions).uniq!.sort!
        end
        
        y.lines.each do |line|
          for i in 0 ... @repetitions_by_line[line].size
            if @repetitions_by_line[line][i][0].id == y.id
              @repetitions_by_line[line][i][0] = x
              x.lines << line unless x.lines.index line
            end
          end
        end
      end
    end
  end
end
