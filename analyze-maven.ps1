# Script PowerShell pour analyser un projet Maven avec SonarQube
# Usage: .\analyze-maven.ps1 -ProjectKey "Student_class" -Token "VOTRE_TOKEN" [-Port 9000]

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectKey,
    
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [string]$HostUrl = "http://localhost"
)

$SonarUrl = "$HostUrl`:$Port"

Write-Host "=== Analyse SonarQube ===" -ForegroundColor Cyan
Write-Host "Project Key: $ProjectKey" -ForegroundColor Yellow
Write-Host "SonarQube URL: $SonarUrl" -ForegroundColor Yellow

# Vérifier que pom.xml existe
if (-not (Test-Path "pom.xml")) {
    Write-Host "ERREUR: pom.xml introuvable dans le répertoire actuel" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire du projet Maven" -ForegroundColor Yellow
    exit 1
}

# Vérifier que SonarQube est accessible
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube est accessible" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: SonarQube n'est pas accessible sur $SonarUrl" -ForegroundColor Red
    Write-Host "Vérifiez que SonarQube est démarré: .\sonarqube-setup.ps1 status" -ForegroundColor Yellow
    exit 1
}

# Construire la commande Maven
Write-Host "`nLancement de l'analyse..." -ForegroundColor Cyan
Write-Host "Commande: mvn clean verify sonar:sonar -Dsonar.projectKey=$ProjectKey -Dsonar.host.url=$SonarUrl -Dsonar.login=***" -ForegroundColor Gray

# Exécuter l'analyse
mvn clean verify sonar:sonar `
    -Dsonar.projectKey=$ProjectKey `
    -Dsonar.host.url=$SonarUrl `
    -Dsonar.login=$Token

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Analyse réussie ===" -ForegroundColor Green
    Write-Host "Consultez les résultats sur: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
} else {
    Write-Host "`n=== Erreur lors de l'analyse ===" -ForegroundColor Red
    exit 1
}

