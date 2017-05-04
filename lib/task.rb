require 'tasks/task_persistence'
require 'tasks/task_object'

class Task
  STATES = {
    complete: 'complete',
    uncomplete: 'uncomplete'
  }.freeze
  extend TaskPersistence
  include TaskObject
end
