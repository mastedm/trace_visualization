module TraceVisualization
  module Mapping
    require 'time'
    require 'ipaddr'

    require 'trace_visualization/reorder'
    
    PATTERNS = {
    
      "id" => [
        /(?<value>\[\d{3,}\])/
      ],

      "ip" => [
        /(?<value>(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/
      ],
    
      "time" => [
        /(?<value>\[\d{2} [a-zA-Z]{3} \d{4} \d{2}\:\d{2}\:\d{2}\])/
      ]

    }
    
    class Item
      include Comparable
  
      attr_reader :value # integer value for comparison
      attr_reader :src   # source value 
      attr_reader :type  # source type

      attr_accessor :ord # re-order value
  
      def initialize(src, type)
        @src  = src
        @type = type
    
        case type
        when "id"
          @value = @src[1 ... -1].to_i
        when "ip"
          @value = IPAddr.new(src).to_i
        when "time"
          @value = Time.parse(@src[1 ... -1]).to_i
        when "char"
          @value = src.getbyte(0)
        else
          raise Exception.new("unknown type")
        end
      end
  
      def length
        @src.length
      end
  
      def <=>(anOther)
        @ord <=> anOther.ord
      end
      
      def to_str
        @src
      end
    end

    def self.parse(str)
      map = {}
      ppos = []
      itemByPos = {}
    
      PATTERNS.each do |type, patterns|
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
          i += item.length
          j += 1
        else
          result << Item.new(str[i], "char")
          i += 1
        end        
      end
      
      TraceVisualization::Reorder.process(result)
      
      result
    end
     
    def self.match(str, type, pattern, map, ppos, itemByPos)
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

    def self.restore(array)
      array.inject("") { |res, c| res += c.to_str }
    end
    
  end
end
