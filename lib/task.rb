require 'tasks/task_persistence'
require 'tasks/task_object'

class Task
  STATES = {
    complete: 'complete',
    incomplete: 'incomplete'
  }.freeze
  extend TaskPersistence
  include TaskObject
end
