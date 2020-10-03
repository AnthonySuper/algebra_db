module AlgebraDB
  ##
  # Class that builds syntax.
  class SyntaxBuilder
    def initialize(params = [])
      @params = params
      @syntax = +''
    end

    def text(str)
      @syntax << str
      @syntax << ' '
    end

    def text_nospace(str)
      @syntax << str
    end

    def param(param)
      text "$#{@params.length + 1}"
      @params << param
    end

    def separate(listish, separator: ',')
      raise ArgumentError, 'need a block' unless block_given?

      len = listish.length
      listish.each.with_index do |e, i|
        yield e, self
        unless (i + 1) == len
          @syntax.strip!
          text(separator)
        end
      end
    end

    def parenthesize
      raise ArgumentError, 'need a block' unless block_given?

      text_nospace('(')
      yield self
      @syntax.strip!
      text(')')
    end

    def syntax
      @syntax.dup
    end

    def params
      @params.map(&:dup)
    end
  end
end
