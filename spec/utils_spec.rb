require 'trace_visualization'
require 'trace_visualization/utils'

require 'tempfile'

include TraceVisualization

describe Utils do
  it "read file test" do
    file = Tempfile.new('trace_visualization_test')
    begin
      file.write("first line\r\nsecond line\r\nthird line")
      file.close
      
      str = Utils.read_file({
        :file_name => file.path,
        :n_lines => 2
      })
      
      expect(str).to eq "first line\r\nsecond line\r\n"
    ensure 
      file.close
      file.unlink
    end
  end
  
  it 'correctly process set_default_options' do
    default = { :offset => 0, :limit => 100 }

    options = {}
    Utils.set_default_options(options, default)
    options.should eq ({ :offset => 0, :limit => 100 })
    
    options = { :offset => 100 }
    Utils.set_default_options(options, default)
    options.should eq ({ :offset => 100, :limit => 100 })
    
    options = { :limit => 100, :qty => 42 }
    Utils.set_default_options(options, default)
    options.should eq ({ :offset => 0, :limit => 100, :qty => 42 })
  end
end