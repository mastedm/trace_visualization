$LOAD_PATH.unshift(File.expand_path('../', __FILE__))
require 'irepetition'

module TraceVisualization
  module Data
    class Repetition < RepetitionBase
      @@sequence = 0
  
      attr_accessor :score
      attr_accessor :pcount
      attr_reader :left_positions, :right_positions
      attr_reader :id
      attr_accessor :strict_ids
  
      def to_s
        "Repetition ##{self.id}: score = #{@score}, k = #{@k}, " + 
        "length = #{@length}, " + 
        "positions.size = #{@left_positions.size}, " + 
        "left_positions = #{@left_positions}, " +
        "right_positions = #{@right_positions}, " +
        "strict_ids = #{@strict_ids}, " + 
        "lines = #{lines}, " +
        "left = #{@left != nil ? @left.id : 'nil'}, " +
        "right = #{@right != nil ? @right.id : 'nil'}"
      end

      def initialize(length, left_positions, right_positions = nil)
        super()
    
        @k = 0
        @pcount = 1
        @length = length
    
        @left_positions  = left_positions
        @right_positions = right_positions 
    
        @id = (@@sequence += 1)
        @strict_ids = [ @id ]
      end
  
      def ==(other_repetition)
        @length == other_repetition.length && 
          @left_positions == other_repetition.left_positions && 
          @right_positions == other_repetition.right_positions
      end

      def positions_size
        @left_positions.size
      end
  
      def get_left_pos(idx)
        @left_positions[idx]
      end
  
      def set_left_pos(idx, val)
        @left_positions[idx] = val
      end
  
      def get_right_pos(idx)
        @right_positions != nil ? @right_positions[idx] : -1
      end
  
      def equal_positions?(r)
        @left_positions == r.left_positions && 
        @right_positions == r.right_positions
      end
  
      # Build positions for hl print:
      #   [
      #     [[pos, len], [], ... ],
      #     [[pos, len], [], ... ],
      #     ...  
      #   ]
      def build_positions
        result = []
    
        @left_positions.each do |lpos|
          result << build_positions_for_repeat(lpos)
        end
    
        result 
      end
  
      #-------------------------------------------------------------------------
      #   [[pos, len], [], ... ]
      def build_positions_for_repeat(pos)
        result = []

        for i in 0 ... positions_size
          lpos, rpos = get_left_pos(i), get_right_pos(i)
          if lpos == pos
            if @k == 0
              result += [[lpos, left_length()]]
            else
              result += left.build_positions_for_repeat(lpos)
              result += right.build_positions_for_repeat(rpos)
            end
          end
        end
    
        result
      end
    end
  end # module Data
end # module TraceVisualization

