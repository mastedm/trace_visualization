require 'trace_visualization/assert'

module TraceVisualization
  module Utils
    
    def self.rhash(lp, rp)
      lp.hash + rp.hash
    end
    
    
    # Get the start position of lines
    def self.lines_pos(str)
      TraceVisualization.assert_instance_of(str, String)
      
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
    
    # Read data from file
    # Allowed options
    #   file_name file name
    #   n_bytes the number of bytes
    #   n_lines the number of lines
    # 
    # If both options - n_bytes and n_lines - are set, it uses n_bytes
    def self.read_file(options)
      str = nil

      if options[:file_name]
        str = ""
        if options[:n_bytes] != nil 
          str = IO.read(options[:file_name], options[:n_bytes])
        else
          fd = open(options[:file_name])
          limit = options[:n_lines] || 2**32
          
          begin
            while (line = fd.readline)
              str += line

              limit -= 1
              break if limit == 0
            end
          rescue EOFError => e
          end
        end
      end
      
      str
    end
    
  end # module Utils
end # module TraceVisualization
