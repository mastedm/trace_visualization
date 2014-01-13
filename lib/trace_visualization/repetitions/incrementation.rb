require 'trace_visualization'

module TraceVisualization
  module Repetitions
    module Incrementation
      
      # Process
      def self.process(context, options = {})
        Utils.set_default_options(options, { 
          :k => 1, :common_positions_size => 2
        })

        k = options[:k]
        repetitions = context.repetitions
        
        result = []

        for core in repetitions
          next if core.k != 0
      
          # Positions for Right Incrementation
          positions_ri = []
      
          # Positions for Left Incrementation
          positions_li = []
      
          for r in repetitions
            next if r == core || core.length + k != r.length
        
            clps, rlps = core.left_positions, r.left_positions
        
            common_positions_ri = clps & rlps
            common_positions_li = clps.collect { |p| p - k } & rlps
                              
            positions_ri |= common_positions_ri if common_positions_ri.size >= options[:common_positions_size]
            positions_li |= common_positions_li if common_positions_li.size >= options[:common_positions_size]
          end
      
          if positions_ri.size > 1
            left_positions  = positions_ri.sort
            right_positions = left_positions.collect { |pos| pos + core.length + k }
        
            hash = TraceVisualization::Utils.rhash(left_positions, right_positions)
        
            unless context.hashes.include? hash
              context.hashes << hash
              result << create_repetition(core, k, left_positions, right_positions, :right)
            end
          end
      
          if positions_li.size > 1
            left_positions  = positions_li.sort
            right_positions = left_positions.collect { |pos| pos + k}
        
            hash = TraceVisualization::Utils.rhash(left_positions, right_positions)
        
            unless context.hashes.include? hash
              context.hashes << hash
              result << create_repetition(core, k, left_positions, right_positions, :left)
            end
          end
        end

        context.repetitions.concat(result)
      end

      # Create repetition
      def self.create_repetition(core, k, left_positions, right_positions, type)
        repetition = core.class.new(core.length + k, left_positions, right_positions)
        repetition.k = k

        fake = fake_repetition(core.class, left_positions, right_positions, type)

        if type == :left
          repetition.left, repetition.right = fake, core
        else
          repetition.left, repetition.right = core, fake
        end

        repetition
      end

      # Create fake repetition
      def self.fake_repetition(cls, left_positions, right_positions, type)
        cls.new(0, type == :left ? left_positions : right_positions)
      end
    end
  end
end