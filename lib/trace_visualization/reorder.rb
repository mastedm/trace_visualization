module TraceVisualization
  module Reorder

    # Assign new values (ord field) in order to reduce the distance between min
    # and max values. It's necessary to reduce the size of the alphabet.
    def self.process(data)
      sorted = data.sort do |a, b|
        c = a.value - b.value
        c == 0 ? 0 : (c < 0 ? -1 : 1) 
      end
      
      idx = 0
      prev = nil
      
      sorted.each do |item|
        if prev != item.value
          prev = item.value
          idx += 1
        end

        item.ord = idx
      end
    end
  end
end
