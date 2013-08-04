=begin
The Burrows–Wheeler transform (BWT, also called block-sorting compression), is 
an algorithm used in data compression techniques such as bzip2. When a character 
string is transformed by the BWT, none of its characters change value. The 
transformation permutes the order of the characters. If the original string had 
several substrings that occurred often, then the transformed string will have 
several places where a single character is repeated multiple times in a row. 
This is useful for compression, since it tends to be easy to compress a string 
that has runs of repeated characters by techniques such as move-to-front 
transform and run-length encoding.

The transform is done by sorting all rotations of the text in lexicographic 
order, then taking the last column. For example, the text "^BANANA|" is 
transformed into "BNN^AA|A".
=end

module TraceVisualization
  module BurrowsWheelerTransform
    
    def self.naive(str)
      (0 ... str.length).collect{ |i| (str * 2)[i, str.length]}.sort.map{|x| x[-1]}
    end
    
    # Attention! This implementation work correctly only when the string ends 
    # with TERMINATION_CHAR that greater of all possible chars in the
    # lexicographical order
    def self.bwt(str, sa, n)
  		Array.new(n) { |i| str[sa[i] - 1] }		
    end
    
  end
end
