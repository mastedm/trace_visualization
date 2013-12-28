require 'trace_visualization'

include TraceVisualization

describe TraceVisualization::Visualization::ConsoleColorPrint do
  it 'smoke' do
    data = <<-LOG
sergey-macbook login[4077] <Notice>: USER_PROCESS: 4077 ttys001
sergey-macbook loginwindow[4215] <Notice>: USER_PROCESS: 4215 console
LOG

    mapping = TraceVisualization::Mapping.new
    mapping.process { from_string(data) }
  
    rs = Repetitions.psy1(mapping, 2, true)
    
    RepetitionsScore.fill_score(rs, :sort => true, :order => 'desc', :version => 'relative')
    
    Visualization::ConsoleColorPrint.hl(mapping, rs[0]).should eq <<-EOL
sergey-macbook login[4077#{Visualization::ConsoleColorPrint::GRN}] <Notice>: USER_PROCESS: 4#{Visualization::ConsoleColorPrint::FINISH}077 ttys001
sergey-macbook loginwindow[4215#{Visualization::ConsoleColorPrint::GRN}] <Notice>: USER_PROCESS: 4#{Visualization::ConsoleColorPrint::FINISH}215 console
EOL
   .chomp
    
  end
end