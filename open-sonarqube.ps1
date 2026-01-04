# Script pour ouvrir SonarQube dans le navigateur
# Usage: .\open-sonarqube.ps1

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [string]$HostUrl = "http://localhost"
)

$SonarUrl = "$HostUrl`:$Port"

Write-Host "Ouverture de SonarQube..." -ForegroundColor Cyan
Write-Host "URL: $SonarUrl" -ForegroundColor Yellow

# Vérifier l'accessibilité
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube est accessible" -ForegroundColor Green
} catch {
    Write-Host "ATTENTION: SonarQube ne semble pas accessible" -ForegroundColor Yellow
    Write-Host "Démarrez SonarQube avec: .\sonarqube-setup.ps1 start" -ForegroundColor Yellow
}

# Ouvrir dans le navigateur
Start-Process $SonarUrl

Write-Host "`nInstructions:" -ForegroundColor Cyan
Write-Host "1. Connectez-vous avec admin/admin" -ForegroundColor White
Write-Host "2. Créez le projet 'StudentClass' (Projects > Create Project > Manually)" -ForegroundColor White
Write-Host "3. Générez un token" -ForegroundColor White
Write-Host "4. Lancez: .\quick-analyze.ps1 -Token `"VOTRE_TOKEN`"" -ForegroundColor Cyan

