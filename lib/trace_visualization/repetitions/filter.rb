require 'trace_visualization/utils'
require 'trace_visualization/repetitions/concatenation'
require 'trace_visualization/visualization/console_color_print'

module TraceVisualization
  module Repetitions
    module Filter

      # Filter for strict repetitions
      def self.strict_repetitions_filter(str, context, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3 })
    
        repetitions_filter(str, context, options)
        split(str, context)
        merge(context)
      end
  
      # Filter repetitions
      def self.repetitions_filter(str, context, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3 })
        
        s0 = context.repetitions.size
        
        delete_by_positions_min_size(context, options[:positions_min_size])
        
        s1 = context.repetitions.size
        
        fix_boundaries(str, context.repetitions)
        
        s2 = context.repetitions.size
        
        delete_duplicates(context)
        
        s3 = context.repetitions.size
        
        if options[:log_level] == :info
          d = s0 - s3
          
          if d > 0
            d1, p1 = s0 - s1, ((s0 - s1) * 100.0 / d).round(2)
            d2, p2 = s1 - s2, ((s1 - s2) * 100.0 / d).round(2)
            d3, p3 = s2 - s3, ((s2 - s3) * 100.0 / d).round(2)
          else
            d1 = d2 = d3 = p1 = p2 = p3 = 0
          end
          
          puts "#{Time.now} d = #{d}, " + 
            "delete_by_positions_min_size = #{p1}% (#{d1}), " +
            "fix_boundaries = #{p2}% (#{d2}), " +
            "delete_duplicates = #{p3}% (#{d3})"
        end
      end
  
      # Filter repetitions: Positions min size
      def self.delete_by_positions_min_size(context, positions_min_size)
        context.repetitions.delete_if do |repetition| 
          flag = repetition.positions_size < positions_min_size 
      
          context.delete_repetition(repetition) if flag
      
          flag
        end
      end
  
      # Filter repetitions: Boundaries
      # * Change repetitions with '\n' at the beginning or end  
      def self.fix_boundaries(str, rs)
        rs.each do |r|
          if str[r.get_left_pos(0)].to_str == "\n" && r.length > 1
            for i in 0 ... r.positions_size
              r.set_left_pos(i, r.get_left_pos(i) + 1)
            end
            r.length -= 1
          end

          if str[r.get_left_pos(0) + r.length - 1].to_str == "\n"
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
      def self.split(str, context)
        splitted = []
        context.repetitions.delete_if do |r|
          pos = nil
          
          for i in r.get_left_pos(0) ... r.get_left_pos(0) + r.length
            if str[i].to_str == "\n"
              pos = i
              break
            end
          end
          
          if pos != nil
            left_part_length = pos - r.get_left_pos(0)
            right_part_length = r.length - left_part_length - 1
            
            # right part of split
            if right_part_length >= 2
              length = right_part_length
              positions = (0 ... r.positions_size).collect { |i| r.get_left_pos(i) + left_part_length + 1 }
          
              nr = r.class.new(length, positions)
          
              splitted << nr
            end
        
            # left part of split
            if left_part_length >= 2
              r.length = left_part_length
              splitted << r
            end
          end
      
          context.delete_repetition(r) if pos != nil
      
          (pos != nil)
        end
    
        splitted.delete_if do |r|
          flag = false

          context.repetitions.each do |x|
            flag = ((x.left_positions & r.left_positions).size == r.left_positions.size && x.length >= r.length)
            break if flag
          end

          flag
        end

        Concatenation.process_new_repetitions(splitted, context)
        context.repetitions.concat(splitted)
      end
  
      # Filter repetitions: delete duplicate
      def self.delete_duplicates(context)
        table, result = {}, []
          
        for repetition in context.repetitions
          until table[repetition.length]
            table[repetition.length] = {}
          end
          
          until table[repetition.length][repetition.left_positions.size]
            table[repetition.length][repetition.left_positions.size] = {}
          end
          
          until table[repetition.length][repetition.left_positions.size][repetition.k]
            table[repetition.length][repetition.left_positions.size][repetition.k] = []
          end
          
          if table[repetition.length][repetition.left_positions.size][repetition.k].find{ |r| r == repetition }.nil?
            table[repetition.length][repetition.left_positions.size][repetition.k] << repetition
            result << repetition
          else
            original = table[repetition.length][repetition.left_positions.size][repetition.k].find{ |r| r == repetition }

            # puts ">>>>>>>>>>"
            # puts "Delete repetition"
            # TraceVisualization::Visualization::ConsoleColorPrint.print_tree(repetition)
            # 
            # puts "Original"
            # TraceVisualization::Visualization::ConsoleColorPrint.print_tree(original)
            # 
            # TraceVisualization::Visualization::ConsoleColorPrint.hl_stdout(context.mapping, repetition)
            # TraceVisualization::Visualization::ConsoleColorPrint.hl_stdout(context.mapping, original)
            
            context.delete_repetition(repetition)
          end
        end
        
        context.repetitions.replace(result)
      end
      
      # Merge repetitions with common positions
      def self.merge(context)
        i = 0
        while i < context.repetitions.size
          j = 0
          while j < context.repetitions.size
            
            if i != j
              x, y = context.repetitions[i], context.repetitions[j]
              if x.length == y.length && x.k == y.k
                common_positions = x.left_positions & y.left_positions
                if common_positions.size == y.left_positions.size
                  context.delete_repetition(y)
                  context.repetitions.delete_at(j) 
                elsif common_positions.size > 0
                  context.merge_repetitions(x, y)
                  context.repetitions.delete_at(j)
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