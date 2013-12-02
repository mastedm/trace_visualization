require 'trace_visualization'

module TraceVisualization
  module Repetitions
    module Concatenation

      def self.process(rs, k, context, options = {})
        Utils.set_default_options(options, { :positions_min_size => 3 })
  
        result = []
  
        useful_cnt = 0

        pairs_cnt = {}
        context.repetitions_by_line.each do |item|
          for i in 0 ... item.size
            for j in i + 1 ... item.size
              left, right = item[i][0], item[j][0]
              delta = k - left.k - right.k

              next if not concat_condition(left, right, delta, options[:positions_min_size])

              key = (left.id << 32) + right.id
              val = (pairs_cnt[key] || 0) + 1
              pairs_cnt[key] = val
              next if val != options[:positions_min_size]

              lps, rps = process_common_positions(left, right, delta, context)
      
              if lps.size >= options[:positions_min_size]
                result << create_repetition(left, right, delta, lps, rps)
              end
      
              useful_cnt += 1        
            end
          end
        end
  
        options[:counter] << [k, useful_cnt] if options[:counter]
  
        puts "Total: #{rs.size ** 2} #{useful_cnt} #{result.size}"
  
        process_new_repetitions(result, context)
  
        rs.concat(result)
      end

      def self.process_new_repetitions(rs, context)
        context.init_repetitions_by_line(rs)
      end

      def self.process_full_search(rs, k, context, options = {})
        opts = {
          :positions_min_size => 3
        }.merge options
  
        result = []
  
        useful_cnt = 0

        for left in rs
          for right in rs
            delta = k - left.k - right.k
            next if not concat_condition(left, right, delta, options[:positions_min_size])
      
            # @@processed_path.add(key(left, right, delta))  
      
            lps, rps = process_common_positions(left, right, delta, context)
      
            if lps.size >= options[:positions_min_size]
              result << create_repetition(left, right, delta, lps, rps)
            end
      
            useful_cnt += 1
          end
        end

        puts "Total: #{rs.size ** 2} #{useful_cnt} #{result.size}"
  
        rs.concat(result)
      end

      # Condition for potential concatenation
      def self.concat_condition(left, right, delta, positions_min_size)
        delta >= 0 && left.id != right.id && 
          left.positions_size  >= positions_min_size && 
          right.positions_size >= positions_min_size
      end

      # *Attention* Position arrays are modified in place which can lead to side 
      # effects. Don't send left == right!
      def self.process_common_positions(left, right, delta, context)
        lr_pos = left.left_positions
        lr_pos.collect! { |pos| pos + left.length + delta }

        rr_pos = right.left_positions
  
        cpr = lr_pos & rr_pos
        cpl = cpr.collect { |pos| pos - left.length - delta }
  
        idx = 0
        while idx < cpr.size
          xxx = context.data[cpl[idx] + left.length ... cpr[idx]]
          xxx = xxx.join if xxx.instance_of? Array
          if xxx.scan(TraceVisualization::FORBIDDEN_CHARS).size != 0
            cpr.delete_at(idx)
            cpl.delete_at(idx)
          else
            idx += 1
          end
        end

        lr_pos.collect! { |lpos| lpos - left.length - delta }
      
        [cpl, cpr]
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