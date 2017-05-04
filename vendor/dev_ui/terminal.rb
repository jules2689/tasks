require 'dev_ui'
require 'io/console'

module DevUI
  module Terminal
    def self.width
      if console = IO.console
        console.winsize[1]
      else
        80
      end
    end
  end
end
