Task
---

![Usage](https://cloud.githubusercontent.com/assets/3074765/25690782/d56c2ffe-3062-11e7-8d98-1639943e312b.png)

A super simple command line application to handle tasks. Stores tasks in a YAML file.

## Usage

1. Clone this repo
2. Add the path of the bin folder for the repo to your `PATH` variable.

## Utility Usage

All usage can be seen through `task help` as well.
All uses of `tasks` can be replaced with `t` 

#### List Task
`task list` OR `task l` OR `task`: list all incomplete tasks
`task list all` OR `task l all` : list all tasks

#### Adding a task
`task add [TITLE]` OR `task a [TITLE]` : Add a task

#### Completing a task
`task complete [ID]` OR `task c [ID]` : Mark a task as complete

#### Marking a task as incomplete
`task uncomplete [ID]` OR `task u [ID]` : Mark a task as complete

#### Deleting a task
`task delete [ID]` OR `task d [ID]` : Delete a task

## Config

A YAML file at `~/.task.config.yml` can be used to specify a few options.

- `data` can be specified, which changes where the YAML file for your tasks are stored
- `airtable` integration can be specified, which will sync your todos to [Airtable](https://airtable.com)
    ```yaml
    airtable:
      api_key: KEY
      app_key: KEY
    ```

#### Example

(with all options)

```yaml
data: ~/Dropbox/tasks.yml
airtable:
  api_key: KEY
  app_key: KEY
```

## Airtable

Airtable is a great online spreadsheet-like tool. It has a great API and allows you to do some cool stuff that normal spreadsheets can't do. See Config to see how to enable it. Once you do, run `task airtable_sync` to synchronize your current tasks.
