require 'trace_visualization/bwt'
require 'trace_visualization/suffix_array'
require 'trace_visualization/longest_common_prefix'
require 'trace_visualization/data/repetition'

module TraceVisualization
  module Repetitions
    
    # Computes all the complete nonextendible repeats using PSY1 algorithm
    # @param data [Array] Array of objects
    # @param p_min [Integer] The minimum number of positions in which we have repetition
    # @param decode_result [Boolean]
    def self.psy1(data, p_min, decode_result = true)
      raise ArgumentError, 'Data is empty' if data == nil || data.size == 0
      
      sa  = TraceVisualization::SuffixArray.effective(data)
      lcp = TraceVisualization::LongestCommonPrefix.effective(data, sa, data.size)
      bwt = TraceVisualization::BurrowsWheelerTransform.bwt(data, sa, data.size)
      
      result = psy1_original(lcp, bwt, p_min, data.length)
      result = decode_psy1_result(result, sa) if decode_result
      
      result
    end

    ##
    # PSY1 computes all the complete nonextendible repeats in 'str' of length
    # p >= p_min. Complexity: \Theta(n)
    #
    # Article: Fast Optimal Algorithms for Computing All the Repeats is a String
    # by Simon J. Puglisi, William F. Smyth, Munina Yusufu
    def self.psy1_original(_LCP, _BWT, p_min, n)
      result = []
    
      lcp = -1
      lb = 0
      bwt1 = _BWT[0]
            
      _LB = []
      _LB.push(:lcp => lcp, :lb => lb, :bwt => bwt1)
            
      for j in 0 ... n
        lb = j
              
        lcp  = j + 1 < n ? _LCP[j + 1] : -1
        bwt2 = j + 1 < n ? _BWT[j + 1] : TraceVisualization::TERMINATION_CHAR
              
        bwt = le_letter(bwt1, bwt2)
        bwt1 = bwt2
              
        while _LB.last()[:lcp] > lcp
          prev = _LB.pop()
                      
          if prev[:bwt] == TraceVisualization::TERMINATION_CHAR && prev[:lcp] >= p_min
            result.push(:lcp => prev[:lcp], :i => prev[:lb], :j => j)
          end
                      
          lb = prev[:lb]
          _LB.last()[:bwt] = le_letter(prev[:bwt], _LB.last()[:bwt])
          bwt = le_letter(prev[:bwt], bwt)
        end
              
        if _LB.last()[:lcp] == lcp
          _LB.last()[:bwt] = le_letter(_LB.last()[:bwt], bwt)
        else
          _LB.push(:lcp => lcp, :lb => lb, :bwt => bwt)
        end
      end
    
      result    
    end
    
    def self.le_letter(l1, l2)
      (l1 == TraceVisualization::TERMINATION_CHAR || l1 != l2) ? TraceVisualization::TERMINATION_CHAR : l1
    end
    
    def self.decode_psy1_result(result, sa)
      repetitions = []

      result.each do |item|
        positions = (item[:i] .. item[:j]).collect { |idx| sa[idx] }
        repetitions << TraceVisualization::Data::Repetition.new(item[:lcp], positions.sort)
      
      end
      
      repetitions
    end
    
  end # module Repetitions
end # module TraceVisualization
