require 'dev_ui'

module DevUI
  module Frame
    def self.inset(text, color: DevUI::Color::CYAN, text_color: DevUI::Color::RESET)
      color + DevUI::Box::Heavy::VERT + text_color + ' ' + text
    end

    def self.top_edge(text, color: DevUI::Color::CYAN)
      edge(text, color: color, first: DevUI::Box::Heavy::TL)
    end

    def self.bottom_edge(text, color: DevUI::Color::CYAN)
      edge(text, color: color, first: DevUI::Box::Heavy::BL)
    end

    def self.edge(text, color: raise, first: raise)
      prefix = color + first + (DevUI::Box::Heavy::HORZ * 2)
      text ||= ''
      unless text.empty?
        prefix << ' ' << text
      end

      textwidth = DevUI::ANSI.printing_width(prefix)
      termwidth = DevUI::Terminal.width
      termwidth = 30 if termwidth < 30

      if textwidth > termwidth
        prefix = prefix[0...termwidth]
        textwidth = termwidth
      end
      padwidth = termwidth - textwidth
      pad = DevUI::Box::Heavy::HORZ * padwidth

      prefix + color + pad + DevUI::Color::RESET + "\n"
    end
  end
end
