require 'trace_visualization'
require 'trace_visualization/bwt'
require 'trace_visualization/mapping'
require 'trace_visualization/suffix_array'

describe TraceVisualization::BurrowsWheelerTransform do
  it "naive approach" do
    str = "^BANANA|"
    
    bwt = TraceVisualization::BurrowsWheelerTransform.naive(str)
    
    bwt.should eq ["B", "N", "N", "^", "A", "A", "|", "A"]
  end
  
  it "effective implementation" do
    str = "abaababa"

    bwt = TraceVisualization::BurrowsWheelerTransform.bwt(str, TraceVisualization::SuffixArray.effective(str), str.length)
    bwt.should eq ["b", "b", "b", "a", "a", "a", "a", "a"]


    10.times do 
      rnd_str = (0 ... 60).map { (65 + rand(26)).chr }.join + TraceVisualization::TERMINATION_CHAR
    
      sa_naive     = TraceVisualization::SuffixArray.naive(rnd_str)
      sa_effective = TraceVisualization::SuffixArray.effective(rnd_str)
      sa_effective.should eq sa_naive
    
      bwt_naive     = TraceVisualization::BurrowsWheelerTransform.naive(rnd_str)
      bwt_effective = TraceVisualization::BurrowsWheelerTransform.bwt(rnd_str, TraceVisualization::SuffixArray.effective(rnd_str), rnd_str.length)

      bwt_effective.should eq bwt_naive    
    end
  end
  
  it "test with mapping" do
    str = "127.0.0.1 a 127.0.0.1 b" + TraceVisualization::TERMINATION_CHAR
    
    mapped_str = TraceVisualization::Mapping.init do
      default_tokens
    end
    
    mapped_str.process { from_string str }
    
    ip, ws, a, b = mapped_str[0], mapped_str[1], mapped_str[2], mapped_str[6]

    ip.to_str.should eq "127.0.0.1"
    ws.to_str.should eq " "
    a.to_str.should eq "a"
    b.to_str.should eq "b" 

    sa = TraceVisualization::SuffixArray.effective(mapped_str)
    
    (sa.length == mapped_str.length).should be_true

    bwt     = TraceVisualization::BurrowsWheelerTransform.bwt(mapped_str, sa, mapped_str.length)
    bwt_str = bwt.inject("") { |res, c| res += c.to_str }

    if ip < ws
      bwt.should     eq [ip, ip, a, ws, ws, b, ws]
      bwt_str.should eq '127.0.0.1127.0.0.1a  b '
    else
      # TODO Implement!
    end
  end
  
end
