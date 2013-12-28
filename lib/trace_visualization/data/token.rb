module TraceVisualization
  module Data
    class Token
      attr_accessor :name
      attr_accessor :value
      attr_accessor :int_value

      # Length of preprocessed string (see TOKEN_REGEXP)
      attr_accessor :token_length
      
      attr_accessor :ord
  
      def initialize(name, value, int_value = -1)
        @name, @value, @int_value = name, value, int_value
      end
  
      def length
        @value.length
      end
      
      def <=>(anOther)
        @ord <=> anOther.ord
      end
      
      def <(other)
        @ord < other.ord
      end
      
      def to_int
        @ord
      end

      def to_i
        to_int
      end

      def to_str
        @value
      end
      
      def to_s
        to_str
      end
      
      def method_missing(name, *args, &blk)
        raise "Missing method #{name}" 
      end
    end
    
    class TokenPosition
      attr_accessor :token, :pos
      
      def initialize(token, pos)
        @token, @pos = token, pos
      end
    end
  end
end