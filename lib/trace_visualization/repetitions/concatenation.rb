require 'trace_visualization'

module TraceVisualization
  module Repetitions
    module Concatenation

      def self.process(context, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3, :_k => 1 })
        k = options[:_k]
        
        result = []
  
        useful_cnt = 0

        for left in context.repetitions
          for right in context.repetitions
            delta = k - left.k - right.k

            next if not concat_condition(left, right, delta, options[:positions_min_size])
            next if not context.is_unique_strict_ids_set(left, right)

            lps, rps = process_common_positions(left, right, delta, context)
  
            if lps.size >= options[:positions_min_size]
              new_repetition = create_repetition(left, right, delta, lps, rps)

              context.add_strict_ids_set(new_repetition.strict_ids)
              
              result << new_repetition
            end
  
            useful_cnt += 1        
          end
        end

        options[:counter] << [k, useful_cnt] if options[:counter]
  
        process_new_repetitions(result, context)
  
        context.repetitions.concat(result)
      end

      def self.process_new_repetitions(new_repetitions, context)
        context.init_repetitions_by_line(new_repetitions)
      end

      # Condition for potential concatenation
      def self.concat_condition(left, right, delta, positions_min_size)
        delta >= 0 && 
          left.id != right.id &&
          (left.lines & right.lines).size >= positions_min_size
      end
      

      # *Attention* Position arrays are modified in place which can lead to side 
      # effects. Don't send left == right!
      def self.process_common_positions(left, right, delta, context)
        result = context.get_processed_common_positions(left, right, delta)
        
        until result
          lr_pos = left.left_positions
          lr_pos.collect! { |pos| pos + left.length + delta }

          rr_pos = right.left_positions
  
          cpr = lr_pos & rr_pos
          cpl = cpr.collect { |pos| pos - left.length - delta }
  
          idx = 0
          while idx < cpr.size
            xxx = context.mapping[cpl[idx] + left.length ... cpr[idx]]
            xxx = xxx.join if xxx.instance_of? Array
            if xxx.scan(TraceVisualization::FORBIDDEN_CHARS).size != 0
              cpr.delete_at(idx)
              cpl.delete_at(idx)
            else
              idx += 1
            end
          end

          lr_pos.collect! { |lpos| lpos - left.length - delta }
          
          result = [cpl, cpr]
          
          context.add_processed_common_positions(left, right, delta, result)
        end
      
        result
      end

      # Create repetition
      # @param left [TraceVisualization::Repetition] left parent
      # @param right [TraceVisualization::Repetition] right parent
      # @param delta
      # @param lps
      # @param rps
      def self.create_repetition(left, right, delta, lps, rps)
        r = left.class.new(left.length + right.length + delta, lps, rps)

        r.k          = left.k + right.k + delta
        r.pcount     = left.pcount + right.pcount
        r.left       = left
        r.right      = right
        r.strict_ids = left.strict_ids + right.strict_ids

        r
      end
    end
  end
end