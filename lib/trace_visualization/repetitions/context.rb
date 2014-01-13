require 'trace_visualization/utils'

module TraceVisualization
  module Repetitions
    class Context
      attr_accessor :mapping, :repetitions, :repetitions_by_line, :hashes
      
      # HASH: { :strict_ids_hashcode => [ [], [], ...], ... }
      # attr_accessor :strict_ids_processed
      
      def initialize mapping
        @mapping = mapping
        @repetitions_by_line = Array.new(@mapping.lines.size) { [] }
        @hashes = []
        
        @strict_ids_processed = {}
        @processed_common_positions = []
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
      
      def is_unique_strict_ids_set(left, right)
        cc = left.strict_ids + right.strict_ids
        
        @strict_ids_processed[cc.hash].nil? || @strict_ids_processed[cc.hash].index(cc).nil?
      end
      
      def add_strict_ids_set(strict_ids)
        until @strict_ids_processed[strict_ids.hash]
          @strict_ids_processed[strict_ids.hash] = []
        end
        @strict_ids_processed[strict_ids.hash] << strict_ids
      end
      
      def get_processed_common_positions(left, right, delta)
        # key = [ left.left_positions, right.left_positions, delta ]
        # @processed_common_positions[ key ]
        
        result = nil
        
        # if @processed_common_positions[delta]
#           if @processed_common_positions[delta][left.length]
#             if @processed_common_positions[delta][left.length][left.left_positions]
#               result = @processed_common_positions[delta][left.length][left.left_positions][right.left_positions]
#             end
#           end
#         end
        
        result
      end
      
      def add_processed_common_positions(left, right, delta, result)
        # key = [ left.left_positions, right.left_positions, delta ]
        # @processed_common_positions[ key ] = result
        
        # until @processed_common_positions[delta]
#           @processed_common_positions[delta] = []
#         end
#         
#         until @processed_common_positions[delta][left.length]
#           @processed_common_positions[delta][left.length] = {}
#         end
#         
#         until @processed_common_positions[delta][left.length][left.left_positions]
#           @processed_common_positions[delta][left.length][left.left_positions] = {}
#         end
#         
#         @processed_common_positions[delta][left.length][left.left_positions][right.left_positions] = result
      end
    end
  end
end
