# Supabase CDN va supabase.js ni barcha HTML larga qo'shish
$dir = 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik'
$htmlFiles = Get-ChildItem -Path $dir -Filter '*.html' -Recurse

$cdnTag    = '<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>'

foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8

    # Allaqachon Supabase bo'lsa o'tkazib yuborish
    if ($content -match 'supabase\.js') {
        Write-Host "Skipped (already has supabase): $($f.Name)" -ForegroundColor Yellow
        continue
    }

    $isAdmin = $f.FullName -like '*\admin\*'
    $prefix  = if ($isAdmin) { '../' } else { '' }

    $sbTag = "<script src=`"${prefix}js/supabase.js`"></script>"

    # CDN ni i18n.js DAN OLDIN qo'shish (head ichiga)
    $content = $content -replace '(<script src="[^"]*i18n\.js[^"]*"></script>)', "$cdnTag`n  `$1"

    # supabase.js ni main.js DAN KEYIN qo'shish
    $content = $content -replace '(<script src="[^"]*main\.js[^"]*"></script>)', "`$1`n  $sbTag"

    Set-Content $f.FullName -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Updated: $($f.Name)" -ForegroundColor Green
}

Write-Host "`nDone! Supabase qo'shildi." -ForegroundColor Cyan
