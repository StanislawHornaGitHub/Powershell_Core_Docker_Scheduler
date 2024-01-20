for ($i = 0; $i -lt 10; $i++) {
    Write-Host "Hello!"
    Write-Host "It's $($(Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))"
    Start-Sleep -Milliseconds 500
}

exit 12