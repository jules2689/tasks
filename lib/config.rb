require 'yaml'

class Config
  def self.config
    YAML.load_file(File.expand_path('~/.task.config.yml'))
  end
end
