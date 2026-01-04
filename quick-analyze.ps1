# Script rapide pour lancer l'analyse une fois le projet créé dans SonarQube
# Usage: .\quick-analyze.ps1 -Token "VOTRE_TOKEN"

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [string]$HostUrl = "http://localhost"
)

$ProjectKey = "StudentClass"
$SonarUrl = "$HostUrl`:$Port"

Write-Host "=== Analyse SonarQube - StudentClass ===" -ForegroundColor Cyan

# Vérifier que pom.xml existe
if (-not (Test-Path "pom.xml")) {
    Write-Host "ERREUR: pom.xml introuvable" -ForegroundColor Red
    exit 1
}

# Vérifier SonarQube
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube accessible" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: SonarQube non accessible sur $SonarUrl" -ForegroundColor Red
    exit 1
}

# Lancer l'analyse
Write-Host "`nLancement de l'analyse..." -ForegroundColor Cyan
Write-Host "Project Key: $ProjectKey" -ForegroundColor Yellow
Write-Host "SonarQube: $SonarUrl" -ForegroundColor Yellow

mvn clean verify sonar:sonar `
    -Dsonar.projectKey=$ProjectKey `
    -Dsonar.host.url=$SonarUrl `
    -Dsonar.login=$Token

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Analyse réussie ===" -ForegroundColor Green
    Write-Host "Résultats: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
    Start-Process "$SonarUrl/dashboard?id=$ProjectKey"
} else {
    Write-Host "`n=== Erreur lors de l'analyse ===" -ForegroundColor Red
    exit 1
}

