require 'trace_visualization/mapping'

describe TraceVisualization::Mapping do
  it "simple id values" do
    str = "foo[1234]bar[1235]far[1234]"
    
    arr = TraceVisualization::Mapping.parse(str)

    arr.size.should eq(12)

    
    ids = arr.find_all { |item| item.type == "id" }
    ids.size.should eq(3)
    ids[0].src.should eq("[1234]")
    ids[1].src.should eq("[1235]")
    ids[2].src.should eq("[1234]")
    ids[0].should eq(ids[2])
    
    str2 = TraceVisualization::Mapping.restore(arr)
    str2.should eq(str)    
    
  end
  
  it "ip values" do
    str = "user1 ip : 127.0.0.1 \r\nuser2 ip : 127.0.0.2"
    
    arr = TraceVisualization::Mapping.parse(str)
    arr.size.should eq(27)
    
    ips = arr.find_all { |item| item.type == "ip" }
    ips.size.should eq(2)
    ips[0].src.should eq("127.0.0.1")
    ips[1].src.should eq("127.0.0.2")
    
    str2 = TraceVisualization::Mapping.restore(arr)
    str2.should eq(str)
  end
  
  it "compare different types" do
    # Ids
    id_1 = TraceVisualization::Mapping::Item.new("[12345678]", "id")
    id_2 = TraceVisualization::Mapping::Item.new("[12345679]", "id")    
    TraceVisualization::Reorder.process([id_1, id_2])
    
    id_1.should be < id_2
    
    # IPs
    ip_1 = TraceVisualization::Mapping::Item.new("127.0.0.1", "ip")
    ip_2 = TraceVisualization::Mapping::Item.new("127.0.0.2", "ip")
    TraceVisualization::Reorder.process([ip_1, ip_2])
    
    ip_1.should be < ip_2

    # Time
    time_1 = TraceVisualization::Mapping::Item.new("[16 Jan 2013 00:10:00]", "time")
    time_2 = TraceVisualization::Mapping::Item.new("[16 Jan 2013 00:10:01]", "time")    
    TraceVisualization::Reorder.process([time_1, time_2])

    # Different
    TraceVisualization::Reorder.process([time_1, time_2, id_1, ip_1])        

    time_1.should be < time_2
    id_1.should be < ip_1
    id_1.should be < time_1
  end
end

