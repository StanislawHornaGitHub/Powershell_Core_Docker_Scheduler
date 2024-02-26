# pip install requests
# pip install matplotlib
# git config --global user.email "stanislawhorna@outlook.com"
# git config --global user.name "Docker Scheduler (stanislawhorna@outlook.com)"

Import-Module ./Modules/Configuration.psm1
Import-Module ./Modules/Git.psm1
Import-Module ./Modules/Processing.psm1

New-Variable -Name 'JOB_CONFIG' -Value @{} -Scope Global -Force
New-Variable -Name 'INSTANCE_CONFIG' -Value @{} -Scope Global -Force


New-Variable -Name 'PYTHON_DEPENDENCIES_TO_INSTALL' -Value @{} -Scope Global -Force

New-Variable -Name 'CONFIG_BOOL_VALUES' -Value @("Enabled", "DelayedStart") -Scope Global -Force
New-Variable -Name 'CONFIG_INT_VALUES' -Value @("RerunPeriodInSeconds") -Scope Global -Force

function Invoke-Main {
    Get-InstanceConfiguration
    Invoke-GitConfiguration
    Get-JobConfiguration
    Install-PythonDependencies
    Invoke-JobTimingInit
    return $Global:JOB_CONFIG

}




Set-Location -Path $env:SCHEDULER_DIR
Invoke-Main