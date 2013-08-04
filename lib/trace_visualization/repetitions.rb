module TraceVisualization
  module Repetitions

    # The naive approach to finding repetitions in the string.
    # Time complexity: О(n^2)
    def self.naive(str, l)
      result = Array.new(l + 1) { [] }
      result[0] << Array.new(str.length) {|idx| idx + 1 }
    
      for i in 1 .. l
        result[i - 1].each do |item|
          counter = char_counter_inc(str, item, i - 1)
          counter.each do |positions|
            result[i] << positions if positions != nil && positions.size > 1
          end
        end
      end
    
      result[l].sort
    end
    
    # The naive approach to finding repetitions in the string.
    # Time complexity: О(n^2)
    def self.naive_all(str, p_min)
      result = []
    
      result << []
      result[0] << Array.new(str.length) {|idx| idx + 1 }
    
      idx = 1
      while true
        result << []
      
        result[idx - 1].each do |item|
          counter = char_counter_inc(str, item, idx - 1)
          counter.each do |positions|
            if positions != nil && positions.size > 1
              result[idx] << positions
              result[idx - 1].delete_if { |item| item == positions }
            end
          end
        end
      
        break if result.last.size == 0
      
        idx += 1
      end
    
      result[p_min ... -1] || []
    end    
    
    def self.char_counter_inc(str, pos, offset)
      counter = Array.new(256)
    
      pos.each do |pos|
        if pos + offset - 1 < str.length
          c = str[pos + offset - 1].ord
          counter[c] = [] if counter[c] == nil
          counter[c] << pos        
        end
      end
    
      counter
    end
  end
end
