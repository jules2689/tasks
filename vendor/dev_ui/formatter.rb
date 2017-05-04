require 'dev_ui'
require 'strscan'

module DevUI
  class Formatter
    SGR_MAP = {
      # presentational
      'red'     => '31',
      'green'   => '32',
      'yellow'  => '33',
      'blue'    => '34',
      'magenta' => '35',
      'cyan'    => '36',
      'bold'    => '1',

      # semantic
      'error'   => '31', # red
      'success' => '32', # success
      'warning' => '33', # yellow
      'info'    => '34', # blue
      'command' => '36', # cyan
    }.freeze

    GLYPH_MAP = {
      'star'     => DevUI::Glyph::STAR_WITHOUT_RESET,
      'info'     => DevUI::Glyph::INFO_WITHOUT_RESET,
      'question' => DevUI::Glyph::QUESTION_WITHOUT_RESET,
      'check'    => DevUI::Glyph::CHECK_WITHOUT_RESET,
      'x'        => DevUI::Glyph::X_WITHOUT_RESET,
    }.freeze

    BEGIN_EXPR = '{{'
    END_EXPR   = '}}'

    SCAN_FUNCNAME = /\w+:/
    SCAN_GLYPH    = /@\w+}}/
    SCAN_BODY     = /
      .*?
      (
        #{BEGIN_EXPR} |
        #{END_EXPR}   |
        \z
      )
    /x

    def initialize(text)
      @text = text
    end

    def format(sgr_map = SGR_MAP)
      @nodes = []
      parse_body(StringScanner.new(@text))
      content = @nodes.each_with_object(String.new) do |(text, fmt), str|
        str << apply_format(text, fmt, sgr_map)
      end
      # write a RESET unless we already have.
      unless @nodes.size.zero? || @nodes.last[1].empty?
        content << DevUI::Color::RESET
      end
      content
    end

    private

    def apply_format(text, fmt, sgr_map)
      sgr = fmt.each_with_object(String.new('0')) do |name, str|
        str << ';' << sgr_map.fetch(name)
      end
      DevUI::ANSI.sgr(sgr) + text
    end

    def parse_expr(sc, stack)
      if sc.peek(1) == '@'
        match = sc.scan(SCAN_GLYPH)
        glyph_name = match[1..-3]
        emit(GLYPH_MAP.fetch(glyph_name), [])
      else
        match = sc.scan(SCAN_FUNCNAME)
        funcname = match.chop
        stack.push(funcname)
      end
      parse_body(sc, stack)
    end

    def parse_body(sc, stack = [])
      match = sc.scan(SCAN_BODY)
      if match && match.end_with?(BEGIN_EXPR)
        emit(match[0..-3], stack)
        parse_expr(sc, stack)
      elsif match && match.end_with?(END_EXPR)
        emit(match[0..-3], stack)
        stack.pop
        parse_body(sc, stack)
      elsif match
        emit(match, stack)
      else
        emit(sc.rest, stack)
      end
    end

    def emit(text, stack)
      return if text.nil? || text.empty?
      @nodes << [text, stack.dup]
    end
  end
end
