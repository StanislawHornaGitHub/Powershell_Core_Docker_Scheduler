pip install requests
pip install matplotlib
git config --global user.email "stanislawhorna@outlook.com"
git config --global user.name "Docker Scheduler (stanislawhorna@outlook.com)"
while ($true) {
    Write-Host "Hi I am working"
    Start-Sleep -Seconds 10 
}
New-Variable -Name 'CONFIG' -Value @{} -Scope Global -Force

function Invoke-Main {

    
}
function Get-Configuration {
    $Global:CONFIG = Get-Content -Path "$env:SCHEDULER_DIR/Config.json" `
    | ConvertFrom-Json 
    
}

Set-Location -Path $env:SCHEDULER_DIR