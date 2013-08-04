require 'trace_visualization/repetitions_incrementation'
require 'trace_visualization/data/repetition'

describe TraceVisualization::RepetitionsIncrementation do
  it "simple incrementation" do
    str = <<EOF
foo 12
foo 13
foo 12
foo 13
foo 12
foo 13
EOF

    hashes = []

    r1  = TraceVisualization::Data::Repetition.new(5, [0, 7, 14, 21, 28, 35])
    r12 = TraceVisualization::Data::Repetition.new(6, [0, 14, 28])
    r13 = TraceVisualization::Data::Repetition.new(6, [7, 21, 35])

    repetitions = [r1, r12, r13]
    
    TraceVisualization::RepetitionsIncrementation.incrementation(str, repetitions, hashes, 1)
    
    repetition = repetitions[-1]
    
    repetitions.size.should  eq 4
    repetition.length.should eq 6
    repetition.k.should      eq 1
    
    repetition.left_positions.should  eq [0, 7, 14, 21, 28, 35]
    repetition.right_positions.should eq [6, 13, 20, 27, 34, 41]
  end
  
  it "left incrementation" do
    str = <<EOF
12_foo
14_foo
22_foo
24_foo
30_bar
32_foo
34_foo
EOF

    hashes = []

    r1 = TraceVisualization::Data::Repetition.new(4, [2, 9, 16, 23, 37, 44])
    r2 = TraceVisualization::Data::Repetition.new(5, [1, 15, 36])
    r3 = TraceVisualization::Data::Repetition.new(5, [8, 22, 43])

    repetitions = [r1, r2, r3]

    TraceVisualization::RepetitionsIncrementation.incrementation(str, repetitions, hashes, 1)

    repetition = repetitions[-1]
    
    repetitions.size.should  eq 4
    repetition.k.should      eq 1
    repetition.length.should eq 5

    repetition.left_positions.should  eq [1, 8, 15, 22, 36, 43]
    repetition.right_positions.should eq [2, 9, 16, 23, 37, 44]
  end
  
  it "test fake repetition" do
    str = <<EOF
abcde11edcb
abcde22bcde
EOF

    left  = TraceVisualization::Data::Repetition.new(5, [0, 12])
    right = TraceVisualization::Data::Repetition.new(0, [7, 19])
    
    repetition = TraceVisualization::Data::Repetition.new(7, [0, 12], [7, 19])
    repetition.left  = left
    repetition.right = right
    repetition.k     = 2
    
    fake = TraceVisualization::RepetitionsIncrementation.fake_repetition(
      repetition.class, repetition.left_positions, repetition.right_positions, 
      "right"
    )

    right.left_positions.should  eq fake.left_positions
    right.right_positions.should eq fake.right_positions
  end
end
