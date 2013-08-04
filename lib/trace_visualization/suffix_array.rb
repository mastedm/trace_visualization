module TraceVisualization
  module SuffixArray
    def self.naive(str)
      n = str.length

      tmp    = Array.new(n)
      result = Array.new(n)
    
      for i in 0 ... n
        tmp[i] = [str[i .. -1], i]
      end

      tmp.sort! { |x, y| x[0] <=> y[0] }    
    
      for i in 0 ... n
        result[i] = tmp[i][1]
      end
    
      result
    end
  
    def self.effective(str)
      n = str.length
      s = []

      if str.instance_of? String
        str.each_char { |c| s << c.ord }
      elsif str.instance_of? Array
        str.each { |c| s << c.ord }
      end

      3.times { s << 0 }

      suffix_array = Array.new(n + 3, 0)

      effective_linear(s, suffix_array, n, s.max + 1)

      suffix_array[0 ... -3]
    end
  
    # Find the suffix array SA.
  	# Used approach from article "Linear Work Suffix Array Construction" 
    # by Juha Karkkainen, Peter Sanders and Stefan Burkhardt
    def self.effective_linear(s, suffix_array, n, alphabet_size)
  		n0 = (n + 2) / 3
  		n1 = (n + 1) / 3
  		n2 = n / 3
  		n02 = n0 + n2
		
      s12 = Array.new(n02 + 3, 0)
      sa12 = Array.new(n02 + 3, 0)
      s0 = Array.new(n0, 0)
      sa0 = Array.new(n0, 0)
    
  		# Generate positions of mod 1 and mod 2 suffixes
  		# the "+(n0-n1)" adds a dummy mod 1 suffix if n%3 == 1
      i = j = 0
      while (i < n + (n0 - n1))
        if i % 3 != 0
          s12[j] = i
          j += 1
        end
        i += 1
      end
    
  		# LSB radix sort the mod 1 and mod 2 triples
  		radix_pass(s12, sa12, s[2 ... s.length], n02, alphabet_size)
  		radix_pass(sa12, s12, s[1 ... s.length], n02, alphabet_size)
  		radix_pass(s12, sa12, s, n02, alphabet_size)
    
  		# Find lexicographic names of triples
  		name, c0, c1, c2 = 0, -1, -1, -1
      for i in 0 ... n02
  			if (s[sa12[i]] != c0 || s[sa12[i] + 1] != c1 || s[sa12[i] + 2] != c2)
  				name += 1
  				c0 = s[sa12[i]]
  				c1 = s[sa12[i] + 1]
  				c2 = s[sa12[i] + 2]
        end
			
  			if (sa12[i] % 3 == 1) 
  				s12[sa12[i]/3] = name      # Left half
        else
  				s12[sa12[i]/3 + n0] = name # Right half
        end
      end
    
  		# Recurse if names are not yet unique
  		if name < n02
  			effective_linear(s12, sa12, n02, name)
			
  			# Store unique names in s12 using the suffix array
        for i in 0 ... n02
  				s12[sa12[i]] = i + 1
        end
      else
  			# Generate the suffix array of s12 directly
        for i in 0 ... n02
  				sa12[s12[i] - 1] = i
        end
      end
    
  		# Stably sort the mod 0 suffixes from sa12 by their first character
      i, j = 0, 0
      while i < n02
        if sa12[i] < n0
          s0[j] = 3 * sa12[i]
          j += 1
        end
        i += 1
      end
  		radix_pass(s0, sa0, s, n0, alphabet_size)
    
  		# Merge sorted sa0 suffixes and sorted sa12 suffixes
      p, t, k = 0, n0 - n1, 0
    
      while k < n
  			# Pos of current offset 12 suffix
  			i = get_i(n0, sa12, t)
      
  			# Pos of current offset 0 suffix
  			j = sa0[p]
      
        # Different compares for mod 1 and mod 2 suffixes
  			if (sa12[t] < n0 ? leq_pairs(s[i], s12[sa12[t] + n0], s[j], s12[j/3]) : leq_triples(s[i], s[i + 1], s12[sa12[t] - n0 + 1], s[j], s[j + 1], s12[j/3 + n0]))
  				suffix_array[k] = i
  				t += 1
  				if t == n02
  					# Done: only sa0 suffixes left
            k += 1
            while p < n0
              suffix_array[k] = sa0[p]
              p += 1
              k += 1
            end
          end
        else
  				suffix_array[k] = j
  				p += 1;
  				if p == n0
  					# Done: only sa12 suffixes left
            k += 1
            while t < n02
              suffix_array[k] = get_i(n0, sa12, t)
              t += 1
              k += 1
            end				
          end
        end
      
        k += 1
      end
    
    end
  
    private
  
    # Stably sort a[0 .. n - 1] to b[0 .. n - 1] with keys in 0 .. K from r
    # Params:
    # +a+:: positions in r for sort
    # +b+:: sorted positions in r
    # +r+:: source
    # +n+:: number of positions in a and b
    # +k+:: size of alphabet
    def self.radix_pass(a, b, r, n, k)
      c = Array.new(k + 1, 0)
    
      # Count occurrences
      for i in 0 ... n
        c[r[a[i]]] += 1
      end
    
      # Exclusive prefix sums
      sum = 0
      for i in 0 .. k
        t = c[i]
        c[i] = sum
        sum += t
      end
    
      # Sort
      for i in 0 ... n
        b[c[r[a[i]]]] = a[i]
        c[r[a[i]]] += 1
      end
    end
  
  	def self.get_i(n0, sa12, t)
  		sa12[t] < n0 ? sa12[t] * 3 + 1 : (sa12[t] - n0) * 3 + 2
    end

    # Lexicographic order for pairs
  	def self.leq_pairs(a1, a2, b1, b2)
  		a1 < b1 || a1 == b1 && a2 <= b2
    end
	
    # Lexicographic order for triples
  	def self.leq_triples(a1, a2, a3, b1, b2, b3) 
  		a1 < b1 || a1 == b1 && leq_pairs(a2, a3, b2, b3)
    end
  
  end
end
