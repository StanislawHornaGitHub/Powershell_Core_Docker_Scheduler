<#
.DESCRIPTION
    Git module required for TaskScheduler.ps1.
    Defines functions needed to correclty set up Git tools

    Functions:
        Invoke-GitConfiguration: 
            Sets global user.email and user.name for instance in container, so tasks can perform pushes.

.NOTES

    Version:            1.0
    Author:             Stanisław Horna
    Mail:               stanislawhorna@outlook.com
    GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
    Creation Date:      25-Feb-2024
    ChangeLog:

    Date            Who                     What
#>

function Invoke-GitConfiguration {
    $Email = $($Global:INSTANCE_CONFIG.Git.GitUserEmail)
    $Name = $($Global:INSTANCE_CONFIG.Git.GitUserName)
    
    if($null -eq $Email){
        Out-Log -Message "Git user email is not available, skipping Git Configuration" -Type "warning" -Invocation $MyInvocation
        return
    }
    if($null -eq $Name){
        Out-Log -Message "Git user name is not available, skipping Git Configuration" -Type "warning" -Invocation $MyInvocation
        return
    }
    
    git config --global user.email "$($Global:INSTANCE_CONFIG.Git.GitUserEmail)"

    git config --global user.name "$Name  (stanislawhorna@outlook.com)"

    Out-Log -Message "Git utility tool configured" -Type "warning" -Invocation $MyInvocation
}

Out-Log -Message "Module Imported" -Type "info" -Invocation $MyInvocation