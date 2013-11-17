require 'time'
require 'ipaddr'

require 'trace_visualization/reorder'
require 'trace_visualization/lexeme_overlap_filter'
require 'trace_visualization/data/lexeme'

module TraceVisualization
  class Mapping
    TOKEN_REGEXP = /\{TOKEN;(?<name>[a-zA-Z0-9]+);(?<source>[^;]+);(?<value>[0-9]+);(?<kind>[0-9]+)\}/
    
    def initialize
      @tokens_map = {}
      @data       = []
      @lines      = []
    end
    
    def self.init(&block)
      mapping = Mapping.new
      mapping.instance_eval(&block)
      mapping
    end
    
    def process(&block)
      instance_eval(&block)
      @max_value = TraceVisualization::Reorder.process(@data)
    end

    def process_without_reorder(&block)
      instance_eval(&block)
    end

    # Load data from preprocessed file. File is read line by line
    def from_preprocessed_file(path, offset, limit, use_lexeme_table = true)
      validate_file_name_argument(path)

      idx = 0
      open(path) do |fd|
        while (line = fd.gets)
          if idx >= offset && idx < offset + limit
            process_preprocessed_line(line, use_lexeme_table) 
          elsif idx >= offset + limit
            break
          end

          idx += 1
        end
      end
      
      @data.pop
    end

    def from_preprocessed_string(str, use_lexeme_table = true)
      validate_string_argument(str)

      str.split("\n").each do |line|
        process_preprocessed_line(line)
      end
      
      @data.pop
    end
    
    def process_preprocessed_line(line, use_lexeme_table = true)
      @lines << @data.length
      
      lexeme_positions = []
      pos = 0
      while (m = TOKEN_REGEXP.match(line, pos))
        pos = m.begin(0)

        lexeme = install_token_m(m, use_lexeme_table)
        lexeme_positions << TraceVisualization::Data::LexemePos.new(lexeme, pos)

        pos += lexeme.lexeme_length
      end


      pos, idx = 0, 0
      while pos < line.length
        lexeme = nil
        if idx < lexeme_positions.size && lexeme_positions[idx].pos == pos
          lexeme = lexeme_positions[idx].lexeme
          idx += 1
        else
          lexeme = install_token('CHAR', line[pos], line[pos].ord, 1, use_lexeme_table)
        end
        pos += lexeme.lexeme_length
        @data << lexeme
      end
      
      @data << install_lf_token
    end
    
    def install_token(name, lexeme_string, int_value, lexeme_length, use_lexeme_table = true)
      name = name.intern
      
      lexeme = use_lexeme_table ? @tokens_map[lexeme_string] : nil
      
      if lexeme.nil?
        lexeme = TraceVisualization::Data::Lexeme.new(name, lexeme_string, int_value)
        lexeme.lexeme_length = lexeme_length

        @tokens_map[lexeme_string] = lexeme if use_lexeme_table
      end
      
      lexeme
    end

    def install_token_m(m, use_lexeme_table = true)
      install_token(m[:name], m[:source], m[:value].to_i, m.to_s.length, use_lexeme_table)
    end
    
    # Install token with LF (line feed or end of line)
    def install_lf_token
      install_token('CHAR', "\n", 0x0A, 1)
    end
    
    def [](index)
      @data[index]
    end
    
    def length
      @data.length
    end
    
    def size
      length
    end
    
    def <<(object)
      lexeme = install_token('UNKNOWN', object, object.to_i, object.to_s.length)
      lexeme.ord = 0 # fake ord because Reorder already processed
      @data << lexeme
    end
    
    def pop
      @data.pop
    end
    
    def max
      @max_value
    end
    
    def find_all
      @data.find_all { |item| yield(item) }
    end

    # Restore source data
    # @param pos [Integer] begin position
    # @param length [Integer] the length of restore part 
    def restore(pos = 0, length = @data.length)
      @data[pos ... pos + length].inject("") { |res, c| res += c.value }
    end
    
    def to_ary
      @data.collect { |lexeme| lexeme.value }
    end
    
    # @return array of lines positions
    def lines
      @lines
    end
    
    def method_missing(name, *args, &blk)
      raise "Missing method #{name}" 
    end

    private
     
    def validate_file_name_argument(path)
      raise ArgumentError, 'Argument must be a string' if not path.instance_of? String
      raise ArgumentError, 'File path is not defined' if path.empty?
      raise RuntimeError, 'File doesn\'t exists' if not File.exists?(path)
    end

    def validate_string_argument(str)
      raise ArgumentError, 'Argument must be a string' unless str.instance_of? String
      raise ArgumentError, 'String is not defined' if str.empty?
    end

  end
end
