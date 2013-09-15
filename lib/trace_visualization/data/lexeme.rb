module TraceVisualization
  module Data
    class Lexeme
      attr_accessor :name
      attr_accessor :value
      attr_accessor :int_value

      # Length of preprocessed string (see LEXEME_REGEXP)
      attr_accessor :lexeme_length
      
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
    
    class LexemePos
      attr_accessor :lexeme
      attr_accessor :pos
      
      def initialize(lexeme, pos)
        @lexeme, @pos = lexeme, pos
      end
    end
  end
end