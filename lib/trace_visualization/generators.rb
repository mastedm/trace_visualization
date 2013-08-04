module TraceVisualization
  module Generators
    module Thue

      # (2,3)-avoidance string (cube-free string on a binary alphabet)
      # Strings contain many repetitions!
      def self.str_2_3(n)
        return "a" if n == 0
        x = str_2_3(n - 1)
    
        x + invert(x)
      end
  
      # (3,2)-avoidance string (square-free strings on a ternary alphabet).
      # Strings contain no repetitions at all!
      def self.str_3_2(n)
        x = "a"
        n.times do 
          y = ""
          x.each_char do |c|
            case c
            when 'a'
              y += "abcab"
            when 'b'
              y += "acabcb"
            when 'c'
              y += "acbcacb"
            end
          end
          x = y
        end
        x
      end
  
      def self.invert(x)
        str = ""
        x.each_char { |c| str += (c == 'a' ? 'b' : 'a') }
        str    
      end
    end

    module Fibonacci
      def self.str(num)
        a, b = "a", "b"
        num.times do
          a, b = a + b, a
        end
    
        b
      end
    end
  end
end
