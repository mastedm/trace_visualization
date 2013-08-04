require 'trace_visualization/utils'

module TraceVisualization
  module RepetitionsIncrementation
  
    #--------------------------------------------------------------------------
    def self.incrementation(str, repetitions, hashes, k)
      result = []

      for core in repetitions
        next if core.k != 0
      
        # Positions for Right Incrementation
        positions_ri = []
      
        # Positions for Left Incrementation
        positions_li = []
      
        for r in repetitions
          next if r == core || core.length + k != r.length
        
          clps = core.left_positions
          rlps = r.left_positions
        
          common_positions_ri = clps & rlps
          common_positions_li = clps.collect { |p| p - k } & rlps
                              
          positions_ri |= common_positions_ri if common_positions_ri.size > 2
          positions_li |= common_positions_li if common_positions_li.size > 2        
        end
      
        if positions_ri.size > 1
          left_positions  = positions_ri.sort
          right_positions = left_positions.collect { |pos| pos + core.length + k}
        
          hash = TraceVisualization::Utils.rhash(left_positions, right_positions)
        
          if (not hashes.include? hash)
            hashes << hash
            result << create_repetition(core, k, left_positions, right_positions, "right")
          end
        end
      
        if positions_li.size > 1
          left_positions  = positions_li.sort
          right_positions = left_positions.collect { |pos| pos + k}
        
          hash = TraceVisualization::Utils.rhash(left_positions, right_positions)
        
          if (not hashes.include? hash)
            hashes << hash
            result << create_repetition(core, k, left_positions, right_positions, "left")
          end
        end
      end

      repetitions.concat(result)
    end

    #--------------------------------------------------------------------------
    def self.create_repetition(core, k, left_positions, right_positions, type)
      repetition = core.class.new(core.length + k, left_positions, right_positions)
      repetition.k = k

      fake = fake_repetition(core.class, left_positions, right_positions, type)

      if type == "left"
        repetition.left, repetition.right = fake, core
      else
        repetition.left, repetition.right = core, fake
      end

      repetition
    end

    #---------------------------------------------------------------------------
    def self.fake_repetition(cls, left_positions, right_positions, type)
      cls.new(0, type == "left" ? left_positions : right_positions)
    end
  end # module RepetitionsIncrementation
end # module TraceVisualization
