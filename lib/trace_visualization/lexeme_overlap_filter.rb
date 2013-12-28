module TraceVisualization
  module LexemeOverlapFilter
    
    def self.process(token_positions)
      token_positions.sort! { |a, b| a.pos <=> b.pos }
      left_bound = token_positions.inject(0) do |left_bound, token_pos| 
        [token_pos.pos + token_pos.token.length, left_bound].max 
      end
    
      idx, current, result = 0, [], []

      for pos in 0 .. left_bound
  
        i = 0
        while i < current.size
          token_pos = current[i]
    
          if token_pos.pos + token_pos.token.length == pos
            fl_delete_token = false
          
            if current.size == 1
              result << token_pos
              fl_delete_token = true
            else
              if is_longest_token(current, token_pos)
                result << token_pos
                current = []
              else
                fl_delete_token = true
              end
            end
      
            if fl_delete_token
              current.delete_at(i)
              i -= 1
            end      
          end
    
          i += 1
        end

        while idx < token_positions.size && token_positions[idx].pos == pos
          current << token_positions[idx] 
          idx += 1
        end
      end
    
      result
    end
  
    def self.is_longest_token(token_positions, token_pos)
      result = true

      token_positions.each do |other_token_pos|
        if token_pos != other_token_pos && token_pos.token.length < other_token_pos.token.length
          result = false
          break
        end
      end
    
      result
    end
  end
end