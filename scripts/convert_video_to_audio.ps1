param (
    [string]$inputFile,
    [string]$outputFile
)

# Verifica si FFmpeg está instalado
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "FFmpeg no está instalado. Por favor, instálalo primero."
    exit 1
}

# Verifica que el archivo de entrada existe
if (-not (Test-Path $inputFile)) {
    Write-Host "El archivo de entrada no existe: $inputFile"
    exit 1
}

# Ejecuta el comando FFmpeg para extraer el audio
ffmpeg -i $inputFile -q:a 0 -map a $outputFile

# Verifica el código de salida
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al extraer el audio."
    exit 1
} else {
    Write-Host "Audio extraído correctamente: $outputFile"
}
