require 'config'

module TaskPersistence
  def all
    tasks_hash[:tasks].map do |id, task_hash|
      Task.new(task_hash.merge(id: id))
    end
  end

  def find(id)
    all.detect { |t| t.id == id.to_i }
  end

  def update_tasks(new_hash)
    File.write(
      storage_path,
      tasks_hash.merge(tasks: new_hash).to_yaml
    )
  end

  def tasks_hash
    YAML.load_file(storage_path)
  end

  def storage_path
    path = Config.config['data'] || '../../../data/.tasks.yml'
    File.expand_path(path, __FILE__)
  end
end
