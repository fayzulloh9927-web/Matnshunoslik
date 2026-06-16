# Yangi pages/ sahifalariga Supabase CDN va auth.js qo'shish
$pagesDir = 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik\pages'
$htmlFiles = Get-ChildItem -Path $pagesDir -Filter '*.html'

foreach ($f in $htmlFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8

    # Supabase CDN qo'shish (i18n.js dan oldin)
    if ($content -notmatch 'supabase\.js') {
        $cdn = '<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>'
        $content = $content -replace '(<script src="\.\./js/i18n\.js"></script>)', "$cdn`n  `$1"
        Write-Host "CDN qo'shildi: $($f.Name)" -ForegroundColor Cyan
    }

    # js/supabase.js qo'shish (main.js dan keyin)
    if ($content -notmatch 'js/supabase\.js') {
        $content = $content -replace '(<script src="\.\./js/main\.js"></script>)', "`$1`n  <script src=`"../js/supabase.js`"></script>"
        Write-Host "supabase.js qo'shildi: $($f.Name)" -ForegroundColor Cyan
    }

    # auth.js qo'shish (supabase.js dan keyin, </body> dan oldin)
    if ($content -notmatch 'auth\.js') {
        $content = $content -replace '(</body>)', "  <script src=`"../js/auth.js`"></script>`n`$1"
        Write-Host "auth.js qo'shildi: $($f.Name)" -ForegroundColor Green
    }

    Set-Content $f.FullName -Value $content -Encoding UTF8 -NoNewline
}

Write-Host "`nBarcha pages/ fayllari yangilandi!" -ForegroundColor Green
