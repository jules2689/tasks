require 'time'

module TaskObject
  attr_accessor :id, :created_at, :updated_at, :completed_at, :title, :state

  def initialize(task)
    @id           = task[:id]
    @title        = task[:title]
    @state        = task[:state]
    @created_at   = Time.parse(task[:created_at])   if task[:created_at]
    @updated_at   = Time.parse(task[:updated_at])   if task[:updated_at]
    @completed_at = Time.parse(task[:completed_at]) if task[:completed_at]
  end

  def save!
    tasks = Task.tasks_hash[:tasks]
    now = Time.now.utc

    @id ||= (tasks.keys.max || 0) + 1
    @created_at ||= now
    @completed_at ||= now if complete?
    @updated_at = now

    tasks[@id] = to_h
    self.class.update_tasks(tasks)
  end

  def delete!
    tasks = Task.tasks_hash[:tasks]
    tasks.delete(@id)
    self.class.update_tasks(tasks)
  end

  def complete?
    @state == Task::STATES[:complete]
  end

  def mark_complete
    @state = Task::STATES[:complete]
  end

  def to_h
    {
      id:           @id,
      created_at:   @created_at ? @created_at.utc.to_s : nil,
      updated_at:   @updated_at ? @updated_at.utc.to_s : nil,
      completed_at: @completed_at ? @completed_at.utc.to_s : nil,
      title:        @title,
      state:        @state
    }
  end

  def to_s
    glyph = complete? ? DevUI::Glyph::CHECK : DevUI::Glyph::X_GLYPH
    date = @updated_at.getlocal.strftime('%b%e, %l:%M %p')
    "#{glyph} [#{@id}] {{bold:#{@title}}} (#{date})"
  end

  def to_a
    [
      complete? ? DevUI::Glyph::CHECK : DevUI::Glyph::X_GLYPH,
      @id,
      @title,
      @updated_at.getlocal.strftime('%b%e, %l:%M %p')
    ]
  end
end
