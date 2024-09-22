# Verificar si el script se está ejecutando con privilegios de administrador
function Test-IsAdmin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Si no se está ejecutando como administrador, reinicia el script con privilegios elevados
if (-not (Test-IsAdmin)) {
    Start-Process powershell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Aquí va el código que deseas ejecutar con privilegios de administrador
Write-Output "Script se está ejecutando con privilegios de administrador."


    # Verifica si Chocolatey ya está instalado
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Instalando Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey ya está instalado."
    }

    # Instala el paquete ffmpeg
    Write-Host "Instalando ffmpeg..."
    choco install ffmpeg -y

    # Manejo de posibles errores
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ocurrió un error durante la instalación de ffmpeg."
    } else {
        Write-Host "ffmpeg instalado correctamente."
    }