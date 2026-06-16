Add-Type -AssemblyName System.Windows.Forms
$sql = Get-Content 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik\supabase_schema.sql' -Raw -Encoding UTF8
[System.Windows.Forms.Clipboard]::SetText($sql)
Write-Host "SQL clipboard ga ko'chirildi! Supabase SQL Editor da Ctrl+V bosing." -ForegroundColor Green
