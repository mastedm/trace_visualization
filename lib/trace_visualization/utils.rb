module TraceVisualization
  module Utils
    
    def self.rhash(lp, rp)
      lp.hash + rp.hash
    end
    
    # Get the start position of lines
    def self.lines_pos(str)
      lines_pos = [0]
      pos = -1

      while (pos = str.index(/\n/, pos + 1))
        lines_pos << pos + 1 if pos + 1 < str.length
      end
    
      lines_pos
    end
  
    # Repetitions by line
    def self.rs_by_line(rs, lines_pos, rs_by_line)
      for r in rs
        r_pos = r.left_positions
        r.lines = []
        i, j = 0, 0
      
        while (i < lines_pos.size && j < r_pos.size)
          a, b = lines_pos[i], (i + 1 < lines_pos.size ? lines_pos[i + 1] : 2**32)
        
          if a <= r_pos[j] && r_pos[j] < b
            rs_by_line[i] << [r, r_pos[j]]
            r.lines << i
          
            j += 1
          else
            i += 1
          end        
        end
      end

      rs_by_line.each { |item| item.sort! { |a, b| a[1] <=> b[1] } }
    
      rs_by_line
    end  
    
  end # module Utils
end # module TraceVisualization
