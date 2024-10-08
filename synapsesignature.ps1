Clear-Host

Write-Host @"

//   ______  __  __  __   __  ______  ______  ______  ______       ______  ______  ______  __        
//  /\  ___\/\ \_\ \/\ "-.\ \/\  __ \/\  == \/\  ___\/\  ___\     /\__  _\/\  __ \/\  __ \/\ \       
//  \ \___  \ \____ \ \ \-.  \ \  __ \ \  _-/\ \___  \ \  __\     \/_/\ \/\ \ \/\ \ \ \/\ \ \ \____  
//   \/\_____\/\_____\ \_\\"\_\ \_\ \_\ \_\   \/\_____\ \_____\      \ \_\ \ \_____\ \_____\ \_____\ 
//    \/_____/\/_____/\/_/ \/_/\/_/\/_/\/_/    \/_____/\/_____/       \/_/  \/_____/\/_____/\/_____/ 
//                                                                                                                                                                                                                                                       

"@ -ForegroundColor Red
Write-Host ""          
Write-Host -ForegroundColor Blue "by Dagoberto and Ghostzin"
Write-Host -ForegroundColor Red "discord.gg/synapsess"

Write-Host ""
function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

Clear-Host

$host.privatedata.ProgressForegroundColor = "red";
$host.privatedata.ProgressBackgroundColor = "black";

$pathsFilePath = "paths.txt"
if(-Not(Test-Path -Path $pathsFilePath)){
    Write-Warning "The file $pathsFilePath does not exist."
    Start-Sleep 10
    Exit
}

$paths = Get-Content "paths.txt"
$stopwatch = [Diagnostics.Stopwatch]::StartNew()

$results = @()
$count = 0
$totalCount = $paths.Count
$progressID = 1

foreach ($path in $paths) {
    $progress = [int]($count / $totalCount * 100)
    Write-Progress -Activity "Scanning paths..." -Status "$progress% Complete:" -PercentComplete $progress -Id $progressID
    $count++

    Try {
        $fileName = Split-Path $path -Leaf
        $signatureStatus = (Get-AuthenticodeSignature $path 2>$null).Status

        $fileDetails = New-Object PSObject
        $fileDetails | Add-Member Noteproperty Name $fileName
        $fileDetails | Add-Member Noteproperty Path $path
        $fileDetails | Add-Member Noteproperty SignatureStatus $signatureStatus

        $results += $fileDetails
    } Catch {
    }
}

$stopwatch.Stop()

$time = $stopwatch.Elapsed.Hours.ToString("00") + ":" + $stopwatch.Elapsed.Minutes.ToString("00") + ":" + $stopwatch.Elapsed.Seconds.ToString("00") + "." + $stopwatch.Elapsed.Milliseconds.ToString("000")

Write-Host ""
Write-Host "The scan took $time to run." -ForegroundColor Yellow

$results | Out-GridView -PassThru -Title 'Signatures Results'
