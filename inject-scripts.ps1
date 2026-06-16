# Barcha HTML sahifalarga effects.js va ai-assistant.js qo'shish
$dir = 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik'
$htmlFiles = Get-ChildItem -Path $dir -Filter '*.html' -Recurse

foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    
    # Allaqachon effects.js bo'lsa o'tkazib yuborish
    if ($content -match 'effects\.js') {
        Write-Host "Skipped: $($f.Name)" -ForegroundColor Yellow
        continue
    }
    
    $isAdmin = $f.FullName -like '*\admin\*'
    $prefix  = if ($isAdmin) { '../' } else { '' }
    
    $scriptBlock = @"

  <script src="${prefix}js/effects.js"></script>
  <script src="${prefix}js/ai-assistant.js"></script>
</body>
"@
    
    $content = $content -replace '</body>', $scriptBlock
    Set-Content $f.FullName -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Updated: $($f.Name)" -ForegroundColor Green
}

Write-Host "`nDone! All HTML files updated." -ForegroundColor Cyan
