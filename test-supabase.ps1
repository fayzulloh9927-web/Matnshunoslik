$url = 'https://tuypviqtxxzoibtsdowu.supabase.co/rest/v1/mualliflar?select=slug,ismi&limit=5'
$headers = @{
    'apikey'        = 'sb_publishable_tZbP_lnEvQii8XrGFTvRJQ_E0xgSwDC'
    'Authorization' = 'Bearer sb_publishable_tZbP_lnEvQii8XrGFTvRJQ_E0xgSwDC'
}
try {
    $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
    Write-Host "✅ Supabase javob berdi! Mualliflar soni: $($resp.Count)" -ForegroundColor Green
    foreach ($m in $resp) {
        $ismi = $m.ismi
        Write-Host "  - $($m.slug): $($ismi.uz)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Xato: $($_.Exception.Message)" -ForegroundColor Red
}
