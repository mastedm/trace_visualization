module TraceVisualization
  module LongestCommonPrefix
    
    # A linear-time algorithm to compute the longest common prefix information
    # in suffix arrays from article: "Linear-Time Longest-Common-Prefix 
    # Computation in Suffix Arrays and Its Applications" Toru Kasai et al.
    # 
    # The method signature and variable names are stored under the specified 
    # work without changes.
    def self.effective(a, pos, n)
      rank = Array.new(n, 0)
      height = Array.new(n, 0)
    
      for i in 0 ... n
        rank[pos[i]] = i
      end
    
      h = 0
      for i in 0 ... n
        if (rank[i] > 0)
          j = pos[rank[i] - 1]
          while a[i + h] == a[j + h]
            h += 1
          end
          height[rank[i]] = h
          h -= 1 if h > 0
        end
      end
    
      height
    end
    
  end
end
