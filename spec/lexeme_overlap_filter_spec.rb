require 'trace_visualization/lexeme_overlap_filter'
require 'trace_visualization/data/token'

include TraceVisualization::Data

describe TraceVisualization::LexemeOverlapFilter do

  it 'test 1' do
    lexeme2 = Token.new(:name, "aa")
    lexeme3 = Token.new(:name, "aaa")
    lexeme6 = Token.new(:name, "aaaaaa")    
    
    i1 = TokenPosition.new(lexeme2, 2)
    i2 = TokenPosition.new(lexeme2, 6)
    i3 = TokenPosition.new(lexeme2, 10)
    i4 = TokenPosition.new(lexeme6, 8)
    i5 = TokenPosition.new(lexeme3, 3)
    
    lexeme_positions = [i1, i2, i3, i4, i5]
    
    result = TraceVisualization::LexemeOverlapFilter.process(lexeme_positions)
    
    result.should eq [i5, i2, i4]
  end

  it 'test 2' do
    lexeme2 = Token.new(:name, "aa")
    lexeme4 = Token.new(:name, "aaaa")
    
    i1 = TokenPosition.new(lexeme2, 0)
    i2 = TokenPosition.new(lexeme4, 2)
    i3 = TokenPosition.new(lexeme2, 4)
    i4 = TokenPosition.new(lexeme4, 5)
    i5 = TokenPosition.new(lexeme2, 7)
    
    lexemes = [i1, i2, i3, i4, i5]
    
    result = TraceVisualization::LexemeOverlapFilter.process(lexemes)
    
    result.should eq [i1, i2, i5]
  end

  it 'test 3' do
    lexeme1 = Token.new(:name, "a")
    lexeme3 = Token.new(:name, "aaa")
    
    i1 = TokenPosition.new(lexeme1, 1)
    i2 = TokenPosition.new(lexeme1, 3)
    i3 = TokenPosition.new(lexeme3, 0)
    i4 = TokenPosition.new(lexeme3, 3)
    
    lexemes = [i1, i2, i3, i4]
    
    result = TraceVisualization::LexemeOverlapFilter.process(lexemes)
    
    result.should eq [i3, i4]
  end

end