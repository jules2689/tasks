module DevUI
  class StreamPrefixer
    def initialize(prefix, out)
      @prefix = prefix
      @out = out
      @at_start_of_line = true
    end

    def emit(input)
      return if input.size.zero?
      input = input.force_encoding(Encoding::UTF_8)

      write(@prefix) if @at_start_of_line
      @at_start_of_line = input.end_with?("\n")

      # newlines that aren't the last character of the entire string.
      write(input.gsub(/\n(?!\z)/, "\n#{@prefix}"))
    end
    alias_method :call, :emit

    private

    def write(output)
      @out.write(output)
    end
  end
end
