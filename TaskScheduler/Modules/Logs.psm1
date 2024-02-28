<#
.DESCRIPTION
    Logs module required for TaskScheduler.ps1.
    Defines functions to enable script to create log files

    Functions:
        Out-Log: 
            Saves log message to log file and displays it to the console

        Set-LogFileName:
            Sets global variable for log file path based on the current day

        Invoke-LogsCleanup:
            Cleans old log files

.NOTES

    Version:            1.0
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
    Creation Date:      26-Feb-2024
    ChangeLog:

    Date            Who                     What
#>

New-Variable -Name 'LOGS_DIRECTORY' -Value "$($env:SCHEDULER_DIR)/Logs" -Scope Global -Force

if (-not $(Test-Path -Path $Global:LOGS_DIRECTORY)) {
    $null = New-Item -ItemType Directory -Path $Global:LOGS_DIRECTORY
}

function Out-Log {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]$Message,
        [string]$Type,
        [System.Object]$Invocation
    )
    # get timestamp for message
    $Time = (Get-Date).ToString("HH:mm:ss.fff")
    # prepare log line
    $Type = $Type.ToUpper()
    $LogMessage = "$Time - [$Type] - [$($Invocation.MyCommand.Name)] - $Message"
    # Save line to the file
    $LogMessage | Out-File -FilePath $Global:EXECUTION_LOG_PATH -Append

    # Identify the font color for current message
    switch ($Type) {
        "ERROR" {
            $FontColor = "red"
        }
        "WARNING" {
            $FontColor = "DarkYellow"
        }
        Default {
            $FontColor = [System.ConsoleColor].GetEnumValues()[-1]
        }
    }
    # display current message in console
    Write-Host $LogMessage -ForegroundColor $FontColor
    # if log is an error throw it
    if ($($Type) -eq "ERROR") {
        throw $Message
    }
}

function Set-LogFileName {
    $date = (Get-Date).ToString("yyyy-MM-dd")
    New-Variable -Name 'EXECUTION_LOG_PATH' -Value "$($Global:LOGS_DIRECTORY)/$($date)_Execution.log" -Scope Global -Force 
}

function Invoke-LogsCleanup {
    # get all files in Logs directory
    Get-ChildItem -Path $Global:LOGS_DIRECTORY | Sort-Object {
        # sort them descending by date in file name
        $name = $_.Name
        $date = $name.Split("_")[0]
        [System.DateTime]::ParseExact($date , "yyyy-MM-dd", $null)
    } -Descending | ` # skip first X files defined in InstanceConfig.json
        Select-Object -Skip $Global:INSTANCE_CONFIG.Logs.LogsHistoryInDays | `
        ForEach-Object {
            # loop through remaining files and remove them
            $null = Remove-Item -Path $_.FullName -Force
            Out-Log -Message "Log file $($_.Name) is removed" -Type "info" -Invocation $MyInvocation
        }
}

Set-LogFileName
Out-Log -Message "Module Imported" -Type "info" -Invocation $MyInvocation