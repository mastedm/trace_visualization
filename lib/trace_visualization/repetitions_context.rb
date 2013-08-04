require 'trace_visualization/utils'

module TraceVisualization
  module Repetitions
    class Context
      attr_accessor :str, :lines_pos, :rs_by_line
      
      def initialize(str, rs)
        @str        = str
        @lines_pos  = TraceVisualization::Utils.lines_pos(str)
        @rs_by_line = Array.new(@lines_pos.size) { [] }
    
        TraceVisualization::Utils.rs_by_line(rs, @lines_pos, @rs_by_line)
      end
      
    end
  end
end
