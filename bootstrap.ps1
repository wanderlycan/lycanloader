& {
    $ErrorActionPreference = 'Stop'
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if (-not [Environment]::Is64BitOperatingSystem) { throw 'Use Windows de 64 bits.' }
        $downloads = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ErrorAction SilentlyContinue).'{374DE290-123F-4565-9164-39C4925E467B}'
        if (-not $downloads) { $downloads = Join-Path $env:USERPROFILE 'Downloads' }
        $folder = Join-Path ([Environment]::ExpandEnvironmentVariables($downloads)) 'LycanLoader'
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Preparando ferramentas em $folder"
        function Get-ToolFile($uri, $destination) {
            $partial = $destination + '.partial'
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile $partial
                Move-Item -LiteralPath $partial -Destination $destination -Force
            } finally {
                if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force }
            }
        }
        $yt = Join-Path $folder 'yt-dlp.exe'
        if (-not (Test-Path -LiteralPath $yt)) {
            Get-ToolFile 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' $yt
        }
        & $yt --ignore-config -U
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel atualizar o yt-dlp. Tente novamente.' }
        $ffmpeg = Join-Path $folder 'ffmpeg.exe'
        $ffprobe = Join-Path $folder 'ffprobe.exe'
        $deno = Join-Path $folder 'deno.exe'
        $temp = Join-Path $folder ('setup-' + [guid]::NewGuid().ToString('N'))
        try {
            if (-not (Test-Path -LiteralPath $ffmpeg) -or -not (Test-Path -LiteralPath $ffprobe)) {
                New-Item -ItemType Directory -Path $temp -Force | Out-Null
                $zip = Join-Path $temp 'ffmpeg.zip'
                Get-ToolFile 'https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' $zip
                Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $temp 'ffmpeg')
                foreach ($name in @('ffmpeg.exe', 'ffprobe.exe')) {
                    $file = Get-ChildItem -LiteralPath (Join-Path $temp 'ffmpeg') -Recurse -Filter $name | Select-Object -First 1
                    if (-not $file) { throw "Arquivo ausente no pacote: $name" }
                    Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $folder $name) -Force
                }
            }
            if (-not (Test-Path -LiteralPath $deno)) {
                New-Item -ItemType Directory -Path $temp -Force | Out-Null
                $zip = Join-Path $temp 'deno.zip'
                Get-ToolFile 'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip' $zip
                Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $temp 'deno')
                Copy-Item -LiteralPath (Join-Path $temp 'deno\deno.exe') -Destination $deno
            }
        } finally {
            if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
        }
        foreach ($tool in @($yt, $ffmpeg, $ffprobe, $deno)) {
            $versionFlag = if ($tool -in @($ffmpeg, $ffprobe)) { '-version' } else { '--version' }
            & $tool $versionFlag | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "Falha ao verificar $tool" }
        }
        Write-Host 'Ferramentas prontas. Iniciando o download...'
        & $yt --ignore-config --no-playlist --ffmpeg-location $folder --js-runtimes "deno:$deno" --windows-filenames -P $folder -o '%(title)s [%(id)s].%(ext)s' -- __URL__
        if ($LASTEXITCODE -ne 0) { throw 'O download falhou. Confira a mensagem do yt-dlp acima.' }
        Write-Host "Download concluido em $folder"
    } catch {
        Write-Host ("Erro: " + $_.Exception.Message) -ForegroundColor Red
    }
}
