require 'trace_visualization/repetitions'
require 'trace_visualization/generators'

describe TraceVisualization::Repetitions do
  context 'naive implementation' do
    it 'strict repetitions for fibonacci string f6' do
      f6 = TraceVisualization::Generators::Fibonacci.str(6)

      TraceVisualization::Repetitions.naive(f6, 1).should eq([[1, 3, 4, 6, 8, 9, 11, 12], [2, 5, 7, 10, 13]])
      TraceVisualization::Repetitions.naive(f6, 2).should eq([[1, 4, 6, 9, 12], [2, 5, 7, 10], [3, 8, 11]])
      TraceVisualization::Repetitions.naive(f6, 3).should eq([[1, 4, 6, 9], [2, 7, 10], [3, 8, 11]])
      TraceVisualization::Repetitions.naive(f6, 4).should eq([[1, 6, 9], [2, 7, 10], [3, 8]])
      TraceVisualization::Repetitions.naive(f6, 5).should eq([[1, 6, 9], [2, 7]])
      TraceVisualization::Repetitions.naive(f6, 6).should eq([[1, 6]])
      TraceVisualization::Repetitions.naive(f6, 7).should eq([])
    end 
  end
end
