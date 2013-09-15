module TraceVisualization
  module LexemeOverlapFilter
    
    def self.process(lexeme_poss)
      lexeme_poss.sort! { |a, b| a.pos <=> b.pos }
      left_bound = lexeme_poss.inject(0) do |left_bound, lexeme_pos| 
        [lexeme_pos.pos + lexeme_pos.lexeme.length, left_bound].max 
      end
    
      idx, current, result = 0, [], []

      for pos in 0 .. left_bound
  
        i = 0
        while i < current.size
          lexeme_pos = current[i]
    
          if lexeme_pos.pos + lexeme_pos.lexeme.length == pos
            fl_delete_lexeme = false
          
            if current.size == 1
              result << lexeme_pos
              fl_delete_lexeme = true
            else
              if is_longest_lexeme(current, lexeme_pos)
                result << lexeme_pos
                current = []
              else
                fl_delete_lexeme = true
              end
            end
      
            if fl_delete_lexeme
              current.delete_at(i)
              i -= 1
            end      
          end
    
          i += 1
        end

        while idx < lexeme_poss.size && lexeme_poss[idx].pos == pos
          current << lexeme_poss[idx] 
          idx += 1
        end
      end
    
      result
    end
  
    def self.is_longest_lexeme(lexeme_poss, lexeme_pos)
      result = true

      lexeme_poss.each do |other_lexeme_pos|
        if lexeme_pos != other_lexeme_pos && lexeme_pos.lexeme.length < other_lexeme_pos.lexeme.length
          result = false
          break
        end
      end
    
      result
    end
  end
end