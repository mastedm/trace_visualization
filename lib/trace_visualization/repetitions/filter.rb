require 'trace_visualization/utils'
require 'trace_visualization/repetitions/concatenation'

module TraceVisualization
  module Repetitions
    module Filter

      # Filter for strict repetitions
      def self.strict_repetitions_filter(str, rs, concat, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3 })
    
        repetitions_filter(str, rs, concat, options)
        split(str, rs, concat)    
      end
  
      # Filter repetitions
      def self.repetitions_filter(str, repetitions, context, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3 })
    
        repetitions.delete_if do |repetition| 
          flag = repetition.positions_size < options[:positions_min_size] 
      
          context.delete_repetition(repetition) if flag
      
          flag
        end
    
        fix_boundaries(str, repetitions)
        delete_duplicates(repetitions, concat)
      end
  
      # Filter repetitions: Boundaries
      # * Change repetitions with '\n' at the beginning or end  
      def self.fix_boundaries(str, rs)
        rs.each do |r|
          if str[r.get_left_pos(0)] == "\n" && r.length > 1
            for i in 0 ... r.positions_size
              r.set_left_pos(i, r.get_left_pos(i) + 1)
            end
            r.length -= 1
          end
      
          if str[r.get_left_pos(0) + r.length - 1] == "\n"
            r.length -= 1
          end
        end    
      end
  
      # Filter repetitions: Split
      # * Split repetitions with '\n' at the center 
      # * Delete duplicate after split (one repeat a subset of the other)
      #
      # *NB* It has meaning only for the strict repetitions, approximate 
      # repetitions doesn't consist '\n'
      def self.split(str, rs, context)
        splitted = []
        rs.delete_if do |r|
          pos = nil
          
          for i in r.get_left_pos(0) ... r.get_left_pos(0) + r.length
            if str[i].to_str == "\n"
              pos = i
              break
            end
          end
          
          if pos != nil
            # right part of split
            if r.length - pos - 1 >= 2
              length = r.length - pos - 1
              positions = (0 ... r.positions_size).collect { |i| r.get_left_pos(i) + pos + 1}
          
              nr = r.class.new(length, positions)
          
              splitted << nr
            end
        
            # left part of split
            if pos >= 2
              r.length = pos
              splitted << r
            end
          end
      
          context.delete_repetition(r) if pos != nil
      
          (pos != nil)
        end
    
        splitted.delete_if do |r|
          flag = false

          rs.each do |x|
            flag = ((x.left_positions & r.left_positions).size == r.left_positions.size && x.length >= r.length)
            break if flag
          end

          flag
        end

        Concatenation.process_new_repetitions(splitted, context)
    
        rs.concat(splitted)
      end
  
      # Filter repetitions: delete duplicate
      def self.delete_duplicates(repetitions, context)
        i = 0
        while i < repetitions.size
          j = i + 1
          while j < repetitions.size
            if repetitions[i] == repetitions[j]
              context.delete_repetition(repetitions[j])
              repetitions.delete_at(j)
            else
              j += 1
            end        
          end
          i += 1
        end
      end
      
      # Merge repetitions with common positions
      def self.merge(repetitions, context)
        i = 0
        while i < repetitions.size
          j = 0
          while j < repetitions.size
            
            if i != j
              x, y = repetitions[i], repetitions[j]
              if x.length == y.length && x.k == y.k
                common_positions = x.left_positions & y.left_positions
                if common_positions.size == y.left_positions.size
                  context.delete_repetition(y)
                  repetitions.delete_at(j) 
                elsif common_positions.size > 0
                  context.merge_repetitions(x, y)
                  repetitions.delete_at(j)
                end
              end
            end
            
            j += 1
          end
          i += 1
        end
      end

    end # Filter
  end # Repetitions
end # TraceVisualization