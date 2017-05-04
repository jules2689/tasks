require 'dev_ui'

module DevUI
  module Color
    RED     = DevUI::ANSI.sgr('31')
    GREEN   = DevUI::ANSI.sgr('32')
    YELLOW  = DevUI::ANSI.sgr('33')
    BLUE    = DevUI::ANSI.sgr('34')
    MAGENTA = DevUI::ANSI.sgr('35')
    CYAN    = DevUI::ANSI.sgr('36')
    RESET   = DevUI::ANSI.sgr('0')
  end
end
