require 'dev_ui'
require 'terminal-table'
require 'fileutils'
require 'yaml'
require 'task'
require 'integrations/airtable'

VERSION = '0.1.0'.freeze

class TaskEngine
  class << self
    def list_tasks(*args)
      tasks = Task.all

      tasks = if args.include?('--complete')
        tasks.select(&:complete?)
      elsif args.include?('--all')
        tasks
      else # Also --incomplete
        tasks.reject(&:complete?)
      end

      if args.include?('--count')
        puts tasks.size
        return
      end

      table = Terminal::Table.new(
        headings: ['', 'ID', 'Title', 'Updated At'],
        rows: tasks.map(&:to_a),
        style: { width: DevUI::Terminal.width - 2, alignment: :center }
      )
      puts table
    end

    def add_task(*title)
      puts DevUI::Frame.top_edge(DevUI::Glyph::STAR + ' Add ')
      task = Task.new(
        title: title.join(' '),
        state: Task::STATES[:uncomplete]
      )
      task.save!
      Integrations::Airtable.request(air_method: :create, params: task.to_h, task: task)
      puts format_line(task)
      puts DevUI::Frame.bottom_edge(DevUI::Glyph::CHECK + ' Done ')
    end

    def delete_task(task_ids)
      puts DevUI::Frame.top_edge(DevUI::Glyph::STAR + ' Delete ')
      task_ids.split(',').each do |id|
        id.strip!
        task = Task.find(id.to_i)
        if task
          puts format_line("Deleting Task {{bold:#{id}}}")
          task.delete!
          Integrations::Airtable.request(air_method: :delete, id: task.airtable_id)
        else
          puts format_line("Couldn't find task with id {{bold:#{id}}}")
        end
      end
      puts DevUI::Frame.bottom_edge(DevUI::Glyph::CHECK + ' Done ')
    end

    def complete_task(task_ids)
      puts DevUI::Frame.top_edge(DevUI::Glyph::STAR + ' Complete ')
      task_ids.split(',').each do |id|
        id.strip!
        task = Task.find(id)
        if task
          task.mark_complete
          puts format_line(task)
          task.save!
          Integrations::Airtable.request(
            air_method: :update,
            params: { state: task.state },
            id: task.airtable_id,
            task: task
          )
        else
          puts format_line("Couldn't find task with id {{bold:#{id}}}")
        end
      end
      puts DevUI::Frame.bottom_edge(DevUI::Glyph::CHECK + ' Done ')
    end

    def incomplete_task(task_ids)
      puts DevUI::Frame.top_edge(DevUI::Glyph::STAR + ' Complete ')
      task_ids.split(',').each do |id|
        id.strip!
        task = Task.find(id)
        if task
          task.mark_incomplete
          puts format_line(task)
          task.save!
          Integrations::Airtable.request(
            air_method: :update,
            params: { state: task.state },
            id: task.airtable_id,
            task: task
          )
        else
          puts format_line("Couldn't find task with id {{bold:#{id}}}")
        end
      end
      puts DevUI::Frame.bottom_edge(DevUI::Glyph::CHECK + ' Done ')
    end

    def help!
      msg = <<-EOF
Task List

{{bold:Usage}}

{{bold:List Task}}
{{command:task}} {{green:[list | l | <nothing>] {{cyan:[--complete|--incomplete|--all]}} {{cyan:--count}}}}

{{bold:Adding a task}}
{{command:task}} {{green:[add | a]}} [TITLE]

{{bold:Completing a task}}
{{command:task}} {{green:[complete | c]}} [ID]

{{bold:Marking a task as incomplete}}
{{command:task}} {{green:[uncomplete | u]}} [ID]

{{bold:Deleting a task}}
{{command:task}} {{green:[delete | d]}} [ID]
      EOF
      msg.split("\n").each do |line|
        text = DevUI::Formatter.new(line)
        puts DevUI::Frame.inset(text.format)
      end
    end

    def sync_to_airtable
      puts DevUI::Frame.top_edge(DevUI::Glyph::STAR + ' Sync ')
      tasks = Task.all
      tasks.each do |task|
        if task.airtable_id.nil?
          puts format_line("Syncing Task (create) {{bold:#{task.id}}}")
          Integrations::Airtable.request(
            air_method: :create,
            params: task.to_h,
            task: task,
            log: true,
            async: false
          )
        else
          puts format_line("Syncing Task (update) {{bold:#{task.id}}}")
          Integrations::Airtable.request(
            air_method: :update,
            params: task.to_h,
            id: task.airtable_id,
            task: task,
            log: true,
            async: false
          )
        end
      end
      puts DevUI::Frame.bottom_edge(DevUI::Glyph::CHECK + ' Done ')
    end

    private

    def format_line(task)
      text = DevUI::Formatter.new(task.to_s)
      DevUI::Frame.inset(text.format)
    end
  end
end
