module TraceVisualization
  module Reorder

    # Assign new int_values (ord field) in order to reduce the distance between
    # min and max int_values. It's necessary to reduce the size of the alphabet.
    # Return max int_value
    def self.process(data)
      sorted = data.sort { |a, b| a.int_value <=> b.int_value }
      
      termination_chars = []
      
      idx, prev = 0, nil
      sorted.each do |item|
        if prev != item.int_value
          prev = item.int_value
          idx += 1
        end

        if item.int_value == TraceVisualization::TERMINATION_CHAR.ord
          termination_chars << item
          idx -= 1
        else
          item.ord = idx
        end
      end

      if termination_chars.size > 0
        # Set maximal value for termination char
        termination_chars.each { |x| x.ord = idx + 1 }
        idx += 1
      end
      
      idx
    end
  end
end
