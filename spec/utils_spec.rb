require 'trace_visualization/utils'

require 'tempfile'

describe TraceVisualization::Utils do
  it "lines pos" do
    str = "qwerty\r\nqwerty\r\nqwerty"
    lines_pos = TraceVisualization::Utils.lines_pos(str)
    
    lines_pos.should eq [0, 8, 16]    
  end
  
  it "read file test" do
    file = Tempfile.new('trace_visualization_test')
    begin
      file.write("first line\r\nsecond line\r\nthird line")
      file.close
      
      str = TraceVisualization::Utils.read_file({
        :file_name => file.path,
        :n_lines => 2
      })
      
      expect(str).to eq "first line\r\nsecond line\r\n"
    ensure 
      file.close
      file.unlink
    end
  end
end