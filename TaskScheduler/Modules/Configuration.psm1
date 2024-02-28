<#
.DESCRIPTION
    Configuration module required for TaskScheduler.ps1.
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

.NOTES

    Version:            1.0
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
    Creation Date:      26-Feb-2024
    ChangeLog:

    Date            Who                     What
#>

New-Variable -Name 'INSTANCE_CONFIG_FILE_NAME' -Value "InstanceConfig.json" -Scope Global -Force
New-Variable -Name 'JOB_CONFIG_FILE_NAME' -Value "JobConfig.json" -Scope Global -Force

New-Variable -Name 'CONFIG_BOOL_VALUES' -Value @("Enabled", "DelayedStart") -Scope Global -Force
New-Variable -Name 'CONFIG_INT_VALUES' -Value @("RerunPeriodInSeconds") -Scope Global -Force

New-Variable -Name 'PYTHON_DEPENDENCIES_TO_INSTALL' -Value @{} -Scope Global -Force
function Get-InstanceConfiguration {
    $ConfigFilePath = "$env:SCHEDULER_DIR/$INSTANCE_CONFIG_FILE_NAME"
    if (Test-Path -Path $ConfigFilePath) {
        try {
            $JSONconfigFile = Get-Content -Path $ConfigFilePath -ErrorAction Stop | `
                ConvertFrom-Json -AsHashtable -ErrorAction Stop
        }
        catch {
            $_.Exception.Message | Out-Log -Type "error" -Invocation $MyInvocation
        }

        New-Variable -Name 'INSTANCE_CONFIG' -Value $JSONconfigFile -Scope Global -Force
        return
    }
    Out-Log -Message "Instance Config file ($($Global:INSTANCE_CONFIG_FILE_NAME)) does not exist" `
        -Type "error" `
        -Invocation $MyInvocation
}

function Get-JobConfiguration {
    $ConfigFilePath = "$env:SCHEDULER_DIR/$JOB_CONFIG_FILE_NAME"
    if (Test-Path -Path $ConfigFilePath) {
        try {
            $JSONconfigFile = Get-Content -Path $ConfigFilePath -ErrorAction Stop | `
                ConvertFrom-Json -AsHashtable -ErrorAction Stop
        }
        catch {
            $_.Exception.Message | Out-Log -Type "error" -Invocation $MyInvocation
        }
        New-Variable -Name 'JOB_CONFIG' -Value $JSONconfigFile -Scope Global -Force
        Invoke-JobConfiguration
        return
    }
    Out-Log -Message "Job Config file ($($Global:INSTANCE_CONFIG_FILE_NAME)) does not exist" `
        -Type "error" `
        -Invocation $MyInvocation
}

function Invoke-JobConfiguration {
    foreach ($task in $Global:JOB_CONFIG.keys) {
        # Cheking if values are valid
        Out-Log -Message "Converting Bool values for $task" -Type "info" -Invocation $MyInvocation
        foreach ($value in $Global:CONFIG_BOOL_VALUES) {
            try {
                $Global:JOB_CONFIG.$task.$value = [System.Convert]::ToBoolean($($Global:JOB_CONFIG.$task.$value))
            }
            catch {
                $_.Exception.Message | Out-Log -Type "error" -Invocation $MyInvocation
            }
        }
        Out-Log -Message "Converting Int32 values for $task" -Type "info" -Invocation $MyInvocation
        foreach ($value in $Global:CONFIG_INT_VALUES) {
            try {
                $Global:JOB_CONFIG.$task.$value = [System.Convert]::ToInt32($Global:JOB_CONFIG.$task.$value)
            }
            catch {
                $_.Exception.Message | Out-Log -Type "error" -Invocation $MyInvocation
            }
        }
        Out-Log -Message "Checking if executable for $task exists." -Type "info" -Invocation $MyInvocation
        $AbsoluteExecutablePath = "$env:SCHEDULER_DIR/Jobs/$task/$($Global:JOB_CONFIG.$task.'ExecutableToRun')"
        if (-not $(Test-Path -Path "$AbsoluteExecutablePath")) {
            $Global:JOB_CONFIG.$task.'Enabled' = $false
            Out-Log -Message "Executable for $task not found. Task will be disabled" -Type "warning" -Invocation $MyInvocation
            continue
        }
        else {
            $Global:JOB_CONFIG.$task.'ExecutableToRun' = $AbsoluteExecutablePath
            Out-Log -Message "Absolute path to executable for $task is set" -Type "info" -Invocation $MyInvocation
        }
        # Collecting Python Dependencies to install
        if ($Global:JOB_CONFIG.$task.ContainsKey("PythonDependencies")) {
            Out-Log -Message "Collecting Python packages to install for $task" -Type "info" -Invocation $MyInvocation
            $PythonDependeciesList = $Global:JOB_CONFIG.$task.PythonDependencies
            foreach ($module in $PythonDependeciesList) {
                if ($Global:PYTHON_DEPENDENCIES_TO_INSTALL.ContainsKey($module)) {
                    continue
                }
                $Global:PYTHON_DEPENDENCIES_TO_INSTALL.Add($module, "")
            }
        }
    }
    Invoke-JobTimingInit
}

function Install-PythonDependencies {
    foreach ($module in $Global:PYTHON_DEPENDENCIES_TO_INSTALL.keys) {
        Out-Log -Message "Installing Python $module" -Type "info" -Invocation $MyInvocation
        pip install $module | Out-Log -Type "info" -Invocation $MyInvocation
    }
}

function Invoke-JobTimingInit {
    foreach ($task in $Global:JOB_CONFIG.keys) {
        if ($Global:JOB_CONFIG.$task.Enabled -ne $true) {
            continue
        }
        Out-Log -Message "Timer initialization for $task" -Type "info" -Invocation $MyInvocation
        if ($Global:JOB_CONFIG.$task.DelayedStart -ne $true) {
            $Global:JOB_CONFIG.$task.Add("NextRunTime", $(Get-Date))
        }
        else {
            $SecondsToDelay = $Global:JOB_CONFIG.$task."RerunPeriodInSeconds"
            $Global:JOB_CONFIG.$task.Add("NextRunTime", $((Get-Date).AddSeconds($SecondsToDelay)))
        }
    }
}

Out-Log -Message "Module Imported" -Type "info" -Invocation $MyInvocation