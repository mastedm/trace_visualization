# Interface for Repetition 
module IRepetition
  def positions_size; end
  
  def get_id; end
  def get_left_pos(idx);     end
  def get_right_pos(idx);    end
  def set_left_pos(idx,val); end
  
  def left_positions(); end
  def right_positions(); end
  
  def equal_positions?(r); end
  
  def left_length; end
  def right_length; end
  
  def strict_length; end
end

class RepetitionBase
  include IRepetition
  
  attr_accessor :length
  
  # Left and right repeatition involved in merge
  attr_accessor :left, :right
  
  attr_accessor :k

  attr_accessor :lines

  def initialize
    @lines = []
  end
  
  def left_length
    @left  != nil ? @left.length  : @length
  end
  
  def right_length
    @right != nil ? @right.length : @length
  end
  
  # Length of strict repetitions involved in the repetition
  def strict_length
    @length - @k
  end
end
