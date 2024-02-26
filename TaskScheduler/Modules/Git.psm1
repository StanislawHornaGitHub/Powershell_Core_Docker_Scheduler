
function Invoke-GitConfiguration {
    Write-Host "user.email: $($Global:INSTANCE_CONFIG.GitUserEmail)"
    Write-Host "user.name: $($Global:INSTANCE_CONFIG.GitUserName) (stanislawhorna@outlook.com)"
    
    # git config --global user.email "$($Global:INSTANCE_CONFIG.GitUserEmail)"
    
    # $Username = "$($Global:INSTANCE_CONFIG.GitUserName) (stanislawhorna@outlook.com)"
    # git config --global user.name "$Username"
}