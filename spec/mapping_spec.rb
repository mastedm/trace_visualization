require 'trace_visualization'
require 'trace_visualization/mapping'
require 'tempfile'

include TraceVisualization
include TraceVisualization::Data

describe Mapping do
  it 'simple id values' do
    str = "foo{TOKEN;id;1234;1234;1}bar{TOKEN;id;1235;1235;1}far{TOKEN;id;1234;1234;1}"
    
    mapping = Mapping.new
    
    mapping.process do
      from_string(str)
    end
    
    mapping.length.should eq 12
    
    ids = mapping.find_all { |lexeme| lexeme.name == :id }
    ids.size.should eq(3)
    ids[0].value.should eq("1234")
    ids[1].value.should eq("1235")
    ids[2].value.should eq("1234")
    ids[0].should eq(ids[2])    
  end
  
  it 'ip values' do
    str = "user1 ip: {TOKEN;ip;127.0.0.1;123;1} \nuser2 ip: {TOKEN;ip;127.0.0.2;122;1}"
    
    mapping = Mapping.new
    
    mapping.process do
      from_string(str)
    end
    
    mapping.length.should eq 24
    
    ips = mapping.find_all { |lexeme| lexeme.name == :ip }
    ips.size.should eq(2)
    ips[0].value.should eq("127.0.0.1")
    ips[1].value.should eq("127.0.0.2")
  end
  
  it 'token to_i conversion' do
    token = Token.new('unknown', 0, 0)
    token.ord = 0
    token.to_i.should eq 0
  end
  
  it 'item as array index' do
    token = Token.new('unknown', 0, 0)
    token.ord = 1
    array = [0, 1, 2]
    
    array[token].should eq 1
  end

  it 'preprocessed string' do
    str = 'Text {TOKEN;id;[1234];1234;1} text {TOKEN;ip;127.0.0.127;1;1} text'
    
    mapping = Mapping.new
    mapping.process { from_string str }
    
    mapping.size.should eq 18
  end
  
  it 'Mapping.lines should contains positions of lines (from string)' do
    str = "{TOKEN;id;1;1;1}x\n{TOKEN;id;1;1;1}y\n{TOKEN;id;1;1;1}z"
    
    mapping = Mapping.new
    mapping.process { from_string str }
    
    mapping.size.should eq 8
    mapping.lines.should eq [0, 3, 6]    
  end
  
  it 'Mapping.lines should contains positions of lines (from file)' do
    data = <<-DATA
line1
line2
line3
DATA
    
    tmp_file = Tempfile.new('trace_visualization')
    open(tmp_file.path, "w") { |fd| fd.write data }
    
    mapping = Mapping.new
    mapping.process { from_file tmp_file.path }

    tmp_file.close
    tmp_file.unlink
    
    mapping.lines.should eq [0, 6, 12]
  end
  
  it 'subarray method for mapping' do
    mapping = Mapping.new
    mapping.process { from_string "test test test" }
    
    submapping = mapping[5 ... 9]
    submapping.size.should eq 4
    submapping.join.should eq "test"
    
    mapping[0 .. -1].join.should eq "test test test"
  end
  
  it 'forbidden char scan' do
    mapping = Mapping.new
    mapping.process { from_string "test test test" }
    mapping[0 .. -1].join.scan(TraceVisualization::FORBIDDEN_CHARS).size.should eq 0
    
    mapping.process { from_string "test\ntest\ntest" }
    mapping[0 .. -1].join.scan(TraceVisualization::FORBIDDEN_CHARS).size.should_not eq 0
  end
end
