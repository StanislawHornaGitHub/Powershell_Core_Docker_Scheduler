function Invoke-JobTimingInit {
    foreach ($task in $Global:JOB_CONFIG.keys) {
        if ($Global:JOB_CONFIG.$task.Enabled -ne $true) {
            continue
        }
        if ($Global:JOB_CONFIG.$task.DelayedStart -ne $true) {
            $Global:JOB_CONFIG.$task.Add("LastRunTime", $(Get-Date))
        }else {
            $SecondsToDelay = $Global:JOB_CONFIG.$task."RerunPeriodInSeconds"
            $Global:JOB_CONFIG.$task.Add("LastRunTime", $((Get-Date).AddSeconds($SecondsToDelay)))
        }
    }
}
