require 'trace_visualization/assert'

module TraceVisualization
  module Utils
    
    def self.set_default_options(options, default_options)
      options.update(default_options.merge(options))      
    end
    
    def self.rhash(lp, rp)
      lp.hash + rp.hash
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
