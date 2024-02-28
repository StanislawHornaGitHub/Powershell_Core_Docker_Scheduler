<#
.DESCRIPTION
    Processing module required for TaskScheduler.ps1.
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

.NOTES

    Version:            1.0
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
    Creation Date:      26-Feb-2024
    ChangeLog:

    Date            Who                     What
#>
function Start-TaskExecution {
    # Get Task name to run
    $TaskName = Get-NextTaskToRun
    Out-Log -Message "Trying to start $TaskName" -Type "info" -Invocation $MyInvocation

    # Check if Job with current task name is not still running
    try {
        $null = $(Get-Job -Name $TaskName -ErrorAction Stop)

        Out-Log -Message "Previous start of $TaskName did not end. Starting new task is canceled" -Type "warning" -Invocation $MyInvocation
        $SecondsToAdd = $Global:JOB_CONFIG.$TaskName."RerunPeriodInSeconds"
        $Global:JOB_CONFIG.$TaskName.NextRunTime = $((Get-Date).AddSeconds($SecondsToAdd))
        return
    }
    catch {}

    # Get Path variables to be passed to the new process
    $TaskWorkingDir = (
        Get-ChildItem -Path $($Global:JOB_CONFIG.$TaskName.ExecutableToRun)
    ).Directory.FullName

    $ExecutableName = (
        Get-ChildItem -Path $($Global:JOB_CONFIG.$TaskName.ExecutableToRun)
    ).Name

    # Start new process
    Out-Log -Message "Starting Job for $TaskName" -Type "info" -Invocation $MyInvocation
    $null = Start-Job -Name $TaskName `
        -ArgumentList $TaskWorkingDir, $ExecutableName `
        -ScriptBlock {
        param(
            $TaskWorkingDir,
            $ExecutableName
        )
        Set-Location $TaskWorkingDir
        switch ($ExecutableName.Split(".")) {
            "ps1" { 
                pwsh $ExecutableName
            }
            "py" {
                python3 $ExecutableName
            }
            "sh" {
                sh $ExecutableName
            }
            Default {
                & $ExecutableName
            }
        }
    }
    # Update next run time for started process
    Out-Log -Message "Updating next runtime for $TaskName" -Type "info" -Invocation $MyInvocation
    $SecondsToAdd = $Global:JOB_CONFIG.$TaskName."RerunPeriodInSeconds"
    $Global:JOB_CONFIG.$TaskName.NextRunTime = $((Get-Date).AddSeconds($SecondsToAdd))
    return
}

function Remove-CompletedTask {
    $JobToRemove = Get-Job | Where-Object { $_.State -ne "Running" }
    foreach ($task in $JobToRemove) {
        Remove-TaskJob -task $task
    }

}

function Remove-TaskJob {
    param (
        $task
    )
    # Get job status and Processing time
    $JobStatus = $task.State
    $ProcessingTime = $($task.PSEndTime - $task.PSBeginTime).ToString()
    # Set apropriate Log message type to corresponding Job status
    switch ($JobStatus) {
        "Completed" {
            $LogType = "info"
        }
        Default {
            $LogType = "warning"
        }
    }
    # log message and remove job
    Out-Log -Message "Removing $($task.Name) with status: $JobStatus. Processing time: $ProcessingTime" -Type $LogType -Invocation $MyInvocation
    Receive-Job -Job $task
    $task | Remove-Job -Force
}

function Wait-TaskLimit {
    Remove-CompletedTask

    # get number of running jobs
    $RunningTask = Get-Job | Where-Object { $_.State -eq "Running" }
    $NumberOfRunnningJobs = ($RunningTask | Measure-Object).Count
    $RunningJobsLimit = $Global:INSTANCE_CONFIG.Performance.TasksRunningSimultaneouslyLimit

    # check if number of running jobs is not exceeding the limit
    if ($NumberOfRunnningJobs -ge $RunningJobsLimit) {
        # if it is wait until any job will complete the execution 
        Out-Log -Message "Number of currently running tasks: $NumberOfRunnningJobs, Limit: $RunningJobsLimit" -Type "info" -Invocation $MyInvocation
        Out-Log -Message "Waiting for any task to complete: $($($RunningTask.Name -join ", "))" -Type "info" -Invocation $MyInvocation
        $CompletedTask = $(Wait-Job -Job $RunningTask -Any)
        # remove completed job
        Remove-TaskJob -task $CompletedTask
    }
}

function Get-NextTaskToRun {
    # Get the task name which is enabled with closest next run time
    $TaskName = $Global:JOB_CONFIG.Keys | `
        Where-Object { $Global:JOB_CONFIG.$_.Enabled -eq $true } | `
        Sort-Object { $Global:JOB_CONFIG.$_.NextRunTime } | `
        Select-Object -First 1
    return $TaskName
}

function Get-SleepTime {
    $TaskShortestTimeToRun = Get-NextTaskToRun
    # Calculate the time remaining to run next task
    $NextRunTime = $Global:JOB_CONFIG.$TaskShortestTimeToRun.NextRunTime
    $SleepTime = [int](($NextRunTime - (Get-Date)).TotalMilliseconds)
    # If task should be alredy started and the time is below 0 set it to 0 to avoid Start-sleep errors
    if ($SleepTime -lt 0) {
        $SleepTime = 0
    }
    Out-Log -Message "Next task to run: $TaskShortestTimeToRun, will be started in $SleepTime milliseconds" -Type "info" -Invocation $MyInvocation
    return $SleepTime
}

function Invoke-MainLoopSleep {
    # Start sleep for appropriate time period
    $TimeToSleep = Get-SleepTime
    Start-Sleep -Milliseconds $TimeToSleep
}

Out-Log -Message "Module Imported" -Type "info" -Invocation $MyInvocation