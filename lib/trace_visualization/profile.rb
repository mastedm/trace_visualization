module TraceVisualization
  module Profile

    def self.time(name)
      start = Time.now
    
      puts "#{start} Start #{name}"

      yield

      finish = Time.now
    
      puts "#{finish} Finish #{name}"
    
      (finish.to_f - start.to_f).round(3)
    end
  
    def self.processing_time(message, logger = nil, object = nil, method = nil)
      start = Time.now

      yield

      finish = Time.now
    
      puts "#{message}#{object != nil ? (object.send(method)) : ''}, pt = #{(finish.to_f - start.to_f).round(4)} sec"
    end
  
    def self.pt
      start = Time.now

      yield

      finish = Time.now
    
      (finish.to_f - start.to_f).round(4)
    end
  end
end