require 'time'
require 'ipaddr'

require 'trace_visualization/reorder'
require 'trace_visualization/lexeme_overlap_filter'
require 'trace_visualization/data/lexeme'

module TraceVisualization
  class Mapping
    
    attr_accessor :tokens
  
    LEXEME_REGEXP = /\{LEXEME;(?<name>[a-zA-Z0-9]+);(?<source>[^;]+);(?<value>[0-9]+)\}/
    
    DEFAULT_TOKENS = {
      :ID => [ 
        /(?<lexeme>\[\d{3,}\])/, 
        lambda { |source| source[1 ... -1].to_i } 
      ],
      
      :IP => [
        /(?<lexeme>(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/,
        lambda { |source| IPAddr.new(source).to_i }
      ],
        
      :TIME => [
        /(?<lexeme>\[\d{2} [a-zA-Z]{3} \d{4} \d{2}\:\d{2}\:\d{2}\])/,
        lambda { |source| Time.parse(source[1 ... -1]).to_i }
      ]      
    }
    
    def initialize
      # hash map: lexeme-object by lexeme-string
      @lexeme_table = {}
      
      @tokens = {}
      @mapped_str = []
    end
    
    def self.init(&block)
      mapping = Mapping.new
      mapping.instance_eval(&block)
      mapping
    end

    # new    
    def token(name, pattern, converter_func)
      @tokens[name] = [pattern, converter_func]
    end
    
    def default_tokens
      @tokens.merge!(DEFAULT_TOKENS)
    end
    
    # new
    def process(&block)
      instance_eval(&block)
      @max_value = TraceVisualization::Reorder.process(@mapped_str)
    end

    def process_without_reorder(&block)
      instance_eval(&block)
    end

    ##
    # Load data from source file. File is read line by line

    def from_file(path)
      validate_file_name_argument(path)

      open(path) do |fd|
        while (line = fd.gets)
          process_line(line)
        end
      end
    end

    ##
    # Load data from preprocessed file. File is read line by line

    def from_preprocessed_file(path, offset, limit, use_lexeme_table = true)
      validate_file_name_argument(path)

      idx = 0
      open(path) do |fd|
        while (line = fd.gets)
          process_preprocessed_line(line, use_lexeme_table) if (idx >= offset && idx < offset + limit)

          idx += 1
        end
      end
    end

    # new
    def from_string(str)
      validate_string_argument(str)
      
      @str = str

      str.split("\n").each do |line|
        process_line(line)
      end

      @mapped_str.pop if @mapped_str[-1].value == "\n" && str[-1] != "\n"
    end

    def from_preprocessed_string(str, use_lexeme_table = true)
      validate_string_argument(str)

      str.split("\n").each do |line|
        process_preprocessed_line(line)
      end
    end
    
    def process_preprocessed_line(line, use_lexeme_table = true)
      lexeme_positions = []
      pos = 0
      while (m = LEXEME_REGEXP.match(line, pos))
        pos = m.begin(0)

        lexeme = install_lexeme_m(m, use_lexeme_table)
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
          lexeme = install_lexeme('CHAR', line[pos], line[pos].ord, 1, use_lexeme_table)
        end
        pos += lexeme.lexeme_length
        @mapped_str << lexeme
      end

      @mapped_str << install_lexeme('CHAR', "\n", "\n".ord, 1, use_lexeme_table)
    end
    
    # new
    def process_line(line)
      lexeme_poss = []

      @tokens.each do |name, value|
        pattern, converter_func = value
        pos = 0
        while (m = pattern.match(line, pos))
          lexeme_string, pos = m[:lexeme], m.begin(0)
          
          lexeme = install_lexeme(name, lexeme_string, converter_func.call(lexeme_string), lexeme_string.length)
          lexeme_poss << TraceVisualization::Data::LexemePos.new(lexeme, pos)
          
          pos += lexeme_string.length
        end
      end
      
      lexeme_poss = TraceVisualization::LexemeOverlapFilter.process(lexeme_poss)
      
      pos, idx = 0, 0
      while pos < line.length
        lexeme = nil
        if idx < lexeme_poss.size && lexeme_poss[idx].pos == pos
          lexeme = lexeme_poss[idx].lexeme
          idx += 1
        else
          lexeme = install_lexeme('CHAR', line[pos], line[pos].ord, 1)
        end
        pos += lexeme.length
        @mapped_str << lexeme
      end
      
      @mapped_str << install_lexeme('CHAR', "\n", "\n".ord, 1)
    end
    
    def install_lexeme(name, lexeme_string, int_value, lexeme_length, use_lexeme_table = true)
      lexeme = use_lexeme_table ? @lexeme_table[lexeme_string] : nil
      
      if lexeme.nil?
        lexeme = TraceVisualization::Data::Lexeme.new(name, lexeme_string, int_value)
        lexeme.lexeme_length = lexeme_length

        @lexeme_table[lexeme_string] = lexeme if use_lexeme_table
      end
      
      lexeme
    end

    def install_lexeme_m(m, use_lexeme_table = true)
      install_lexeme(m[:name], m[:source], m[:value].to_i, m.to_s.length, use_lexeme_table)
    end
    
    def [](index)
      @mapped_str[index]
    end
    
    def length
      @mapped_str.length
    end
    
    def size
      length
    end
    
    def <<(object)
      lexeme = install_lexeme('UNKNOWN', object, object.to_i, object.to_s.length)
      lexeme.ord = 0 # fake ord because Reorder already processed
      @mapped_str << lexeme
    end
    
    def pop
      @mapped_str.pop
    end
    
    def max
      @max_value
    end
    
    def find_all
      @mapped_str.find_all { |item| yield(item) }
    end

    def restore(pos = 0, length = @mapped_str.length)
      @mapped_str[pos ... pos + length].inject("") { |res, c| res += c.value }
    end
    
    def to_ary
      @mapped_str.collect { |lexeme| lexeme.value }
    end
    
    def method_missing(name, *args, &blk)
      raise "Missing method #{name}" 
    end

    private

    def parse(str)
      map = {}
      ppos = []
      itemByPos = {}
    
      DEFAULT_TOKENS.each do |type, patterns|
        patterns.each do |pattern|
          match(str, type, pattern, map, ppos, itemByPos)
        end
      end
    
      i, j = 0, 0
      result = []
    
      ppos.sort!
    
      while i < str.size
        if i == ppos[j]
          item = itemByPos[ppos[j]]
          result << item
          i, j = i + item.length, j + 1
        else
          result << Item.new(str[i], "char")
          i += 1
        end        
      end
      
      @max_value = TraceVisualization::Reorder.process(result)
      
      result
    end
     
    def match(str, type, pattern, map, ppos, itemByPos)
      pos = 0
      
      limit = 1000
      
      while (m = pattern.match(str, pos))
        value = m[:value]
        pos = m.begin(0)
        ppos << pos
      
        map[value] = Item.new(value, type) unless map[value]
        itemByPos[pos] = map[value]
        
        pos += value.size
      end
      
    end

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
