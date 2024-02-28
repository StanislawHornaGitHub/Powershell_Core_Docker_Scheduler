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

## Configuration
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

Each field is mandatory except "PythonDependencies" which can be removed completely,
if task is not using Python.