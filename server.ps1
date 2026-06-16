$port = 3030
$root = $PSScriptRoot

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server started at http://localhost:$port" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.json' = 'application/json'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.woff2'= 'font/woff2'
    '.woff' = 'font/woff'
    '.ttf'  = 'font/ttf'
    '.mp3'  = 'audio/mpeg'
    '.wav'  = 'audio/wav'
}

while ($listener.IsListening) {
    try {
        $ctx  = $listener.GetContext()
        $req  = $ctx.Request
        $res  = $ctx.Response

        $path = $req.Url.LocalPath.TrimStart('/')
        if ($path -eq '') { $path = 'index.html' }

        $filePath = Join-Path $root $path

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext   = [System.IO.Path]::GetExtension($filePath)
            $mime  = $mimeTypes[$ext]
            if (-not $mime) { $mime = 'application/octet-stream' }

            $res.ContentType     = $mime
            $res.ContentLength64 = $bytes.Length
            $res.StatusCode      = 200
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $res.StatusCode = 404
            $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
            $res.OutputStream.Write($body, 0, $body.Length)
        }
        $res.OutputStream.Close()

    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
