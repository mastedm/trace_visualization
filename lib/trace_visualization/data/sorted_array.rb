module TraceVisualization
  module Data
    class SortedArray < Array
      def self.[] *array
        SortedArray.new(array)
      end

      def initialize(array = nil)
        super( array.sort ) if array
      end

      def << value
        insert index_of_last_LE(value), value
      end

      alias push <<
      alias shift <<

      def index_of_last_LE value
        l, r = 0, length - 1
        while l <= r
          m = (r + l) / 2
          
          if value < self[m]
            r = m - 1
          else
            l = m + 1
          end
        end
        
        l
      end
      
      def index value
        idx = index_of_last_LE(value)
        
        if idx != 0 && self[idx - 1] == value
          idx -= 1 while idx != 0 && self[idx - 1] == value
          idx
        end
      end
    end
  end
end