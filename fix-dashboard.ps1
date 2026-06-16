$file = 'C:\Users\User\.gemini\antigravity\scratch\matnshunoslik\admin\dashboard.html'
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

# Yangi script </script> tugashidan keyin eski kodni topib o'chirish
# Yangi script "DOMContentLoaded', init);" bilan tugaydi
# Keyin </script> keladi - shundan keyin eski kod bor

$marker = "document.addEventListener('DOMContentLoaded', init);`n  </script>"

# Fayl da shu marker bormi
$idx = $content.IndexOf("document.addEventListener('DOMContentLoaded', init);")
if ($idx -lt 0) {
    Write-Host "MARKER TOPILMADI!" -ForegroundColor Red
    exit 1
}

# Eski tag
$oldScriptEnd = '</script>'
$markerEnd = $content.IndexOf($oldScriptEnd, $idx)
$keepUpTo = $markerEnd + $oldScriptEnd.Length

# effects.js qismi
$effectsTag = '<script src="../js/effects.js"></script>'
$effectsIdx = $content.LastIndexOf($effectsTag)

if ($effectsIdx -gt 0) {
    $ending = "`n" + $content.Substring($effectsIdx)
    $newContent = $content.Substring(0, $keepUpTo) + $ending
} else {
    $newContent = $content.Substring(0, $keepUpTo) + "`n</body>`n</html>"
}

[System.IO.File]::WriteAllText($file, $newContent, [System.Text.Encoding]::UTF8)
Write-Host "Tayyor! Fayl hajmi: $([math]::Round($newContent.Length/1KB,1)) KB" -ForegroundColor Green
