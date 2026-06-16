Add-Type -AssemblyName System.IO.Compression.FileSystem

$src = 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik'
$dst = 'C:\Users\User\Desktop\matnshunoslik-deploy.zip'

if (Test-Path $dst) { Remove-Item $dst -Force }

$zip = [System.IO.Compression.ZipFile]::Open($dst, 'Create')

$exclude = @('.git', 'node_modules', '.ps1', '.log', 'matnshunoslik-deploy.zip', 'inject-supabase.ps1', 'inject-auth.ps1', 'copy-sql.ps1', 'test-supabase.ps1')

Get-ChildItem -Path $src -Recurse -File | Where-Object {
    $skip = $false
    foreach ($ex in $exclude) {
        if ($_.FullName -match [regex]::Escape($ex)) { $skip = $true; break }
    }
    -not $skip
} | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length + 1)
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel, 'Optimal') | Out-Null
    Write-Host "  + $rel" -ForegroundColor DarkGray
}

$zip.Dispose()

$sizeMB = [math]::Round((Get-Item $dst).Length / 1MB, 2)
Write-Host ""
Write-Host "ZIP tayyor: $sizeMB MB" -ForegroundColor Green
Write-Host "Joylashuv: $dst" -ForegroundColor Cyan
Write-Host ""
Write-Host "Endi vercel.com/new ga boring va ZIP ni upload qiling!" -ForegroundColor Yellow
