New-Variable -Name 'INSTANCE_CONFIG_FILE_NAME' -Value "InstanceConfig.json" -Scope Global -Force
New-Variable -Name 'JOB_CONFIG_FILE_NAME' -Value "JobConfig.json" -Scope Global -Force

function Get-InstanceConfiguration {
    $ConfigFilePath = "$env:SCHEDULER_DIR/$INSTANCE_CONFIG_FILE_NAME"
    if (Test-Path -Path $ConfigFilePath) {
        $JSONconfigFile = Get-Content -Path $ConfigFilePath | `
            ConvertFrom-Json -AsHashtable
        New-Variable -Name 'INSTANCE_CONFIG' -Value $JSONconfigFile -Scope Global -Force
        return
    }
    throw "Instance Configuration file does not exist"
}

function Get-JobConfiguration {
    $ConfigFilePath = "$env:SCHEDULER_DIR/$JOB_CONFIG_FILE_NAME"
    if (Test-Path -Path $ConfigFilePath) {
        try {
            $JSONconfigFile = Get-Content -Path $ConfigFilePath | `
                ConvertFrom-Json -AsHashtable
        }
        catch {
            throw $_
        }
        New-Variable -Name 'JOB_CONFIG' -Value $JSONconfigFile -Scope Global -Force
        Invoke-JobConfiguration
        return
    }
    throw "Job Configuration file does not exist"
}

function Invoke-JobConfiguration {
    foreach ($task in $Global:JOB_CONFIG.keys) {
        # Cheking if values are valid
        foreach ($value in $Global:CONFIG_BOOL_VALUES) {
            try {
                $Global:JOB_CONFIG.$task.$value = [bool]$Global:JOB_CONFIG.$task.$value
            }
            catch {
                throw $_
            }
        }
        foreach ($value in $Global:CONFIG_INT_VALUES) {
            try {
                $Global:JOB_CONFIG.$task.$value = [int]$Global:JOB_CONFIG.$task.$value
            }
            catch {
                throw $_
            }
        }
        $AbsoluteExecutablePath = "$env:SCHEDULER_DIR/Jobs/$task/$($Global:JOB_CONFIG.$task.'ExecutableToRun')"
        if (-not $(Test-Path -Path "$AbsoluteExecutablePath")) {
            $Global:JOB_CONFIG.$task.'Enabled' = $false
            throw "$task - executable not found"
            continue
        }
        else {
            $Global:JOB_CONFIG.$task.'ExecutableToRun' = $AbsoluteExecutablePath
        }
        # Collecting Python Dependencies to install
        if ($Global:JOB_CONFIG.$task.ContainsKey("PythonDependencies")) {
            $PythonDependeciesList = $Global:JOB_CONFIG.$task.PythonDependencies
            foreach ($module in $PythonDependeciesList) {
                if ($Global:PYTHON_DEPENDENCIES_TO_INSTALL.ContainsKey($module)) {
                    continue
                }
                $Global:PYTHON_DEPENDENCIES_TO_INSTALL.Add($module, "")
            }
        }
    }
}

function Install-PythonDependencies {
    foreach ($module in $Global:PYTHON_DEPENDENCIES_TO_INSTALL.keys) {
        $null = $(pip install $module)
    }
}