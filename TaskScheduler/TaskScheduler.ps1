<#
.SYNOPSIS
    Main Process running constanly in Docker Container, to execute scheduled tasks.

.DESCRIPTION
    Main PowerShell Core process running constanlty in Docker Container responsible for:
        - Running configured tasks at defined times
        - Measuring execution times
        - Cleaning up completed processes
        - Meeting simultaneously running tasks limit

.NOTES

    Version:            1.0
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
    Creation Date:      25-Feb-2024
    ChangeLog:

    Date            Who                     What
#>

############################# BLOCK FOR RUNNING TaskScheduler.ps1 OUTSIDE DOCKER CONTAINER #############################
if ($null -eq $env:SCHEDULER_DIR) {
    $env:SCHEDULER_DIR = `
    "$((($MyInvocation.Statement | Resolve-Path).Path.Split("/") | Select-Object -SkipLast 1) -join "/")"
}
Set-Location -Path $env:SCHEDULER_DIR
if (-not $(Test-Path -Path "./Jobs")) {
    $Source = `
    "$(($env:SCHEDULER_DIR.Split("/") | Select-Object -SkipLast 1) -join "/")/Jobs"
    Copy-Item -Path $Source -Destination $env:SCHEDULER_DIR -Recurse
}
############################# BLOCK FOR RUNNING TaskScheduler.ps1 OUTSIDE DOCKER CONTAINER #############################

Import-Module ./Modules/Logs.psm1
Import-Module ./Modules/Configuration.psm1
Import-Module ./Modules/Git.psm1
Import-Module ./Modules/Processing.psm1

New-Variable -Name 'JOB_CONFIG' -Value @{} -Scope Global -Force
New-Variable -Name 'INSTANCE_CONFIG' -Value @{} -Scope Global -Force



function Invoke-Main {
    Get-InstanceConfiguration
    Invoke-GitConfiguration
    Get-JobConfiguration
    Install-PythonDependencies
    Invoke-MainLoop

}

function Invoke-MainLoop {
    Out-Log -Message "Starting Main While Loop" -Type "info" -Invocation $MyInvocation
    while ($true) {
        Wait-TaskLimit
        
        Start-TaskExecution

        Set-LogFileName
        Invoke-LogsCleanup

        Remove-CompletedTask
        
        Invoke-MainLoopSleep
    }
}

Out-Log -Message "Script started" -Type "info" -Invocation $MyInvocation
Invoke-Main