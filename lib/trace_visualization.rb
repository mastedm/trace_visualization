%w(
  mapping
  utils
  version
).each { |file| require File.join(File.dirname(__FILE__), 'trace_visualization', file) }

require 'logger'
require 'benchmark'

module TraceVisualization

  # Should be 'greater' of all possible chars in the lexicographical order
  TERMINATION_CHAR = 255.chr

  FORBIDDEN_CHARS = /\n/

  #
  # options[:str] 
  # options[:file_name] 
  # 
  def self.process(options = {})
    options = set_default_options(options)
    logger  = options[:logger]

    # Preprocess
    file_name = options[:file_name]

    # Read & mapping file
    mapping = TraceVisualization::Mapping.new
    mapping.process do
      from_preprocessed_file options[:file_name]
    end

=begin
    logger.info 'start process'

    str        = nil
    str_mapped = nil

    Benchmark.bm(14) do |x|
      x.report('read file') { str = options[:str] || TraceVisualization::Utils.read_file(options) }
      x.report('mapping') { str_mapped = TraceVisualization::Mapping.new(str) }
    end
    
    str_len = str.length
    map_len = str_mapped.length
    logger.info("str.length = #{str_len}, str_mapped.length = #{map_len}, compression = #{((str_len.to_f - map_len) / str_len.to_f).round(2)}%")

    return []

    rs = TraceVisualization::Repetitions.psy1(str_mapped, options[:p_min], true)

    logger.info 'PSY1 finish. build context'
    
    context = TraceVisualization::Repetitions::Context.new(str_mapped, rs)
    
    logger.info 'first concat step'
    
    TraceVisualization::RepetitionsConcatenation.process(rs, 1, context)
    
    # Approximate
    # Vissss   
=end
    #rs
  end
  
  def self.set_default_options(options)
    options = {
      :p_min => 3, 
      :logger => Logger.new(STDOUT)
    }.merge options
  end
 
end
