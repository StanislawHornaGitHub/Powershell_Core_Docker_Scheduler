# Task Scheduler Modules
All `.psm1` PowerShell modules defined in this directory are mandatory for `TaskScheduler.ps1`.
They provides all required functionality, when `TaskScheduler.ps1` represents basic logic only.

# Brief modules description
## [`Configutation.psm1`](/TaskScheduler/Modules/Configuration.psm1)
    Defines functions needed to correclty read and init configuration.

    Functions:
        Get-InstanceConfiguration: 
            Reads InstanceConfig.json and stores as Hashtable

        Get-JobConfiguration:
            Reads JobConfig.json and stores as Hashtable

        Invoke-JobConfiguration:
            Configures data read out from file. Converts appropriate values from string to bools or ints.

        Install-PythonDependencies:
            Installs python packages required for configured tasks.

        Invoke-JobTimingInit:
            Creates DateTime object for each configured task.

## [`Git.psm1`](/TaskScheduler/Modules/Git.psm1)
    Defines functions needed to correclty set up Git tools

    Functions:
        Invoke-GitConfiguration: 
            Sets global user.email and user.name for instance in container, so tasks can perform pushes.

## [`Logs.psm1`](/TaskScheduler/Modules/Logs.psm1)
    Defines functions to enable script to create log files

    Functions:
        Out-Log: 
            Saves log message to log file and displays it to the console

        Set-LogFileName:
            Sets global variable for log file path based on the current day

        Invoke-LogsCleanup:
            Cleans old log files

## [`Processing.psm1`](/TaskScheduler/Modules/Processing.psm1)
    Defines functions to handle PowerShell jobs executing configured tasks.

    Functions:
        Start-TaskExecution: 
            Starts PowerShell job for next task to run if last execution is completed.

        Remove-CompletedTask:
            Removes all jobs which are not running.

        Remove-TaskJob:
            Performs actual action of removing job with saving appropriate info to log.

        Wait-TaskLimit:
            Waits until any task will be ended if the limit of simultaneously running jobs is reached.

        Get-NextTaskToRun:
            Returns task name for closest task to run.

        Get-SleepTime:
            Returns number of milliseconds to sleep before running next scheduled task.

        Invoke-MainLoopSleep:
            Sleeps main process to wait until next task run is needed.