module TraceVisualization
  module RepetitionsScore

    # Priority length when repetition score is calculated
    ALPHA_SCORE = 0.5

    # Priority positions.size when repetition score is calculated
    BETA_SCORE = 1 - ALPHA_SCORE

    # Options:
    # *sort* true / false
    # *order* order for sort (default 'asc')
    # *version* version of importance function
    def self.fill_score(rs, options = {})

      opts = {
          :sort => false,
          :order => 'asc'
      }.merge options

      case opts[:version]
        when 'relative'
          function_relative(rs)
        when 'linear'
          function_linear(rs)
        else
          throw Exception.new("Unknown version")
      end

      if opts[:sort]
        rs.sort! do |a, b|
          opts[:order] == 'desc' ? b.score <=> a.score : a.score <=> b.score
        end
      end
    end

    # f(len, size) = alpha * len' + beta * size'
    # len', size' - relative to max values
    def self.function_relative(rs)
      len_max, size_max = 0, 0

      rs.each do |r|
        len = r.length
        len_max = len if len > len_max

        size = r.positions_size
        size_max = size if size > size_max
      end

      rs.each do |r|
        r.score = ALPHA_SCORE * r.strict_length / len_max +
            BETA_SCORE * r.positions_size / size_max
      end
    end

    # f(len, size, k) = alpha * len + beta * size + gamma * k
    def self.function_linear(rs)
      len_max, len_min, size_max, size_min, k_max = 0, 2**32, 0, 2**32, 0

      rs.each do |r|
        len = r.length
        len_max = len if len > len_max
        len_min = len if len < len_min

        size = r.positions_size
        size_max = size if size > size_max
        size_min = size if size < size_min

        k_max = r.k if r.k > k_max
      end

      d = (len_max * size_min + size_max * k_max - size_max * len_min - len_max * k_max).to_f

      alpha =  (size_min + k_max * (size_max - 1)) / d
      beta  = - (len_min + k_max * (len_max - 1)) / d
      gamma = (len_max * size_min - size_max * len_min - size_min + len_min) / d

      puts "len_max = #{len_max}, len_min = #{len_min}, size_max = #{size_max}, size_min = #{size_min}, k_max = #{k_max}"
      puts "alpha = #{alpha}, beta = #{beta}, gamma = #{gamma}"

      rs.each do |r|
        r.score = alpha * r.length + beta * r.positions_size + gamma * r.k
      end
    end

  end
end