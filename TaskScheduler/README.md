# Task Scheduler
`TaskScheduler.ps1` is the main process running inside the Docker Container responsible for all magic.
It relies on Modules defined in [`/TaskScheduler/Modules`](/TaskScheduler/Modules/) Directory. Detailed logs describing what is happening will be displayed in the console and also will be saved to file in `/TaskScheduler/Logs` Directory.

## Container Configuration
All Container related configuration items are located in InstanceConfig.json.

    {
        "Git": {
            "GitUserEmail": <email_to_be_used_in_git_pushes>,
            "GitUserName": <git_user_to_be_used_in_git_pushes>
        },
        "Performance":{
            "TasksRunningSimultaneouslyLimit": <Number_of_tasks_which_can_be_running_at_the_same_time>
        },
        "Logs":{
            "LogsHistoryInDays": <Number_of_days_to_store_logs_from>
        }
    }

Git section is not mandatory if any of tasks is not meant to perform git push

## Tasks Configuration
To schedule task you need to create entry in JobConfig.json to the corresponding task.

    "<Scheduled_Task_Name>": {
        "Enabled": <True_or_False>,
        "DelayedStart": <True_or_False>,
        "RerunPeriodInSeconds": <Time_interval_in_which_task_should_be_invoked>,
        "ExecutableToRun": <Name_of_file_to_run_in_separate_process>,
        "PythonDependencies":[
            <List_of>,
            <Python_packages>,
            <to_install_using>,
            <pip_install_command>
        ]
    }

- <Scheduled_Task_Name> - user friendly name of the configured task. 
It has to match the name of the directory in [`/Jobs`](/Jobs/) where task related files will be stored.

- DelayedStart - will delay the first call of particular task after container startup. 
Start will be delayed by the number of seconds set in RerunPeriodInSeconds.

- RerunPeriodInSeconds - number of seconds in which the task will be started. Time is calculated between task startups,
so execution duration is not considered. It may happen that the set time will be shorter than the processing time of an already running task.

> [!WARNING]
> If task execution time is longer than `RerunPeriodInSeconds`, when Scheduler will try to call the task which is still running,
> it will delay the startup by `RerunPeriodInSeconds`. Such action will be perform until previous execution will be processing

> [!TIP]
> Task execution time can be found in Execution log in format presented below:

    HH:MM:ss.fff - [INFO] - [Remove-TaskJob] - Removing <Scheduled_Task_Name> with status: <Completed/Failure>. Processing time: HH:MM:ss.fffffff

- ExecutableToRun - name of the file which should be called to start the task. 
It must contain an extension to identify if it should be run in Python, PowerShell or Bash.

- PythonDependencies - list of Python packages to be installed using `pip install` command. 
If it is not required it can be completely removed from config for particular task.

