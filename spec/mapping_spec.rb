require 'trace_visualization'
require 'trace_visualization/mapping'

include TraceVisualization
include TraceVisualization::Data

describe TraceVisualization::Mapping do
  it 'simple id values' do
    str = "foo[1234]bar[1235]far[1234]\n"
    
    mapping = TraceVisualization::Mapping.init do
      default_tokens
    end 
    
    mapping.process do
      from_string(str)
    end
    
    mapping.length.should eq 13
    
    ids = mapping.find_all { |lexeme| lexeme.name == :ID }
    ids.size.should eq(3)
    ids[0].value.should eq("[1234]")
    ids[1].value.should eq("[1235]")
    ids[2].value.should eq("[1234]")
    ids[0].should eq(ids[2])
    
    mapping.restore.should eq str
  end
  
  it 'ip values' do
    str = "user1 ip : 127.0.0.1 \r\nuser2 ip : 127.0.0.2\r\n"
    
    mapping = TraceVisualization::Mapping.init do
      default_tokens
    end 
    
    mapping.process do
      from_string(str)
    end
    
    mapping.length.should eq 29
    
    ips = mapping.find_all { |lexeme| lexeme.name == :IP }
    ips.size.should eq(2)
    ips[0].value.should eq("127.0.0.1")
    ips[1].value.should eq("127.0.0.2")
    
    mapping.restore.should eq str
  end
  
  it 'compare different types' do
    mapping = TraceVisualization::Mapping.init do
      default_tokens
    end
    
    mapping.tokens.should_not be_nil
    mapping.tokens[:ID].should_not be_nil
    mapping.tokens[:IP].should_not be_nil
    mapping.tokens[:TIME].should_not be_nil
    
    # Ids
    id_1 = Lexeme.new(:ID, "[12345678]", mapping.tokens[:ID][1].call("[12345678]"))
    id_2 = Lexeme.new(:ID, "[12345679]", mapping.tokens[:ID][1].call("[12345679]"))
    Reorder.process([id_1, id_2])
    
    id_1.should be < id_2
    
    # IPs
    ip_1 = Lexeme.new(:IP, "127.0.0.1", mapping.tokens[:IP][1].call("127.0.0.1"))
    ip_2 = Lexeme.new(:IP, "127.0.0.2", mapping.tokens[:IP][1].call("127.0.0.2"))
    Reorder.process([ip_1, ip_2])
    
    ip_1.should be < ip_2

    # Time
    time_1 = Lexeme.new(:TIME, '[16 Jan 2013 00:10:00]', mapping.tokens[:TIME][1].call('[16 Jan 2013 00:10:00]'))
    time_2 = Lexeme.new(:TIME, '[16 Jan 2013 00:10:01]', mapping.tokens[:TIME][1].call('[16 Jan 2013 00:10:01]'))
    Reorder.process([time_1, time_2])

    # Different
    Reorder.process([time_1, time_2, id_1, ip_1])        

    time_1.should be < time_2
    id_1.should be < ip_1
    id_1.should be < time_1
  end
  
  it 'Lexeme to_i conversion' do
    lexeme = TraceVisualization::Data::Lexeme.new('unknown', 0, 0)
    lexeme.ord = 0
    lexeme.to_i.should eq 0
  end
  
  it 'item as array index' do
    lexeme = TraceVisualization::Data::Lexeme.new('unknown', 0, 0)
    lexeme.ord = 1
    array = [0, 1, 2]
    
    array[lexeme].should eq 1
  end

  it 'preprocessed string' do
    str = 'Text {LEXEME;ID;[1234];1234} text {LEXEME;IP;127.0.0.127;1} text'
    
    mapping = TraceVisualization::Mapping.new
    mapping.process do
      from_preprocessed_string str
    end
    
    mapping.size.should eq 19
  end
end
