# Script complet pour configurer et analyser le projet StudentClass avec SonarQube
# Usage: .\setup-and-analyze.ps1 [-Token "VOTRE_TOKEN"] [-Port 9000]

param(
    [Parameter(Mandatory=$false)]
    [string]$Token = "",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [string]$HostUrl = "http://localhost"
)

$ProjectKey = "StudentClass"
$ProjectName = "StudentClass"
$SonarUrl = "$HostUrl`:$Port"

Write-Host "=== Configuration et Analyse SonarQube ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectName" -ForegroundColor Yellow
Write-Host "SonarQube URL: $SonarUrl" -ForegroundColor Yellow

# Vérifier que pom.xml existe
if (-not (Test-Path "pom.xml")) {
    Write-Host "ERREUR: pom.xml introuvable dans le répertoire actuel" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire du projet Maven" -ForegroundColor Yellow
    exit 1
}

# Vérifier que SonarQube est accessible
Write-Host "`nVérification de SonarQube..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube est accessible" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: SonarQube n'est pas accessible sur $SonarUrl" -ForegroundColor Red
    Write-Host "Démarrez SonarQube avec: .\sonarqube-setup.ps1 start" -ForegroundColor Yellow
    exit 1
}

# Vérifier si le projet existe dans SonarQube
Write-Host "`nVérification de l'existence du projet..." -ForegroundColor Cyan
Write-Host "Ouvrez votre navigateur et vérifiez si le projet '$ProjectName' existe:" -ForegroundColor Yellow
Write-Host "$SonarUrl/projects" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "`n=== ÉTAPE 1: Créer le projet dans SonarQube ===" -ForegroundColor Cyan
    Write-Host "1. Ouvrez: $SonarUrl" -ForegroundColor White
    Write-Host "2. Connectez-vous avec admin/admin (ou vos identifiants)" -ForegroundColor White
    Write-Host "3. Allez dans Projects > Create Project" -ForegroundColor White
    Write-Host "4. Choisissez 'Manually'" -ForegroundColor White
    Write-Host "5. Renseignez:" -ForegroundColor White
    Write-Host "   - Project display name: $ProjectName" -ForegroundColor Gray
    Write-Host "   - Project key: $ProjectKey" -ForegroundColor Gray
    Write-Host "6. Cliquez sur 'Set Up'" -ForegroundColor White
    Write-Host "`n=== ÉTAPE 2: Générer un token ===" -ForegroundColor Cyan
    Write-Host "1. Dans la page du projet, choisissez 'Locally'" -ForegroundColor White
    Write-Host "2. Sélectionnez 'Maven'" -ForegroundColor White
    Write-Host "3. Générez un token (ex: 'Analyze $ProjectName')" -ForegroundColor White
    Write-Host "4. Copiez le token généré" -ForegroundColor White
    Write-Host "`nEnsuite, relancez ce script avec le token:" -ForegroundColor Yellow
    Write-Host ".\setup-and-analyze.ps1 -Token `"VOTRE_TOKEN`"" -ForegroundColor Cyan
    exit 0
}

# Si un token est fourni, lancer l'analyse
Write-Host "`n=== Lancement de l'analyse SonarQube ===" -ForegroundColor Cyan
Write-Host "Project Key: $ProjectKey" -ForegroundColor Yellow
Write-Host "Token: ***" -ForegroundColor Yellow

# Lancer l'analyse Maven
Write-Host "`nExécution de: mvn clean verify sonar:sonar ..." -ForegroundColor Cyan

mvn clean verify sonar:sonar `
    -Dsonar.projectKey=$ProjectKey `
    -Dsonar.host.url=$SonarUrl `
    -Dsonar.login=$Token

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Analyse réussie ===" -ForegroundColor Green
    Write-Host "Consultez les résultats sur: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
    Write-Host "`nOuvrir dans le navigateur..." -ForegroundColor Yellow
    Start-Process "$SonarUrl/dashboard?id=$ProjectKey"
} else {
    Write-Host "`n=== Erreur lors de l'analyse ===" -ForegroundColor Red
    Write-Host "Vérifiez:" -ForegroundColor Yellow
    Write-Host "- Que le projet '$ProjectKey' existe dans SonarQube" -ForegroundColor White
    Write-Host "- Que le token est valide" -ForegroundColor White
    Write-Host "- Que SonarQube est accessible" -ForegroundColor White
    exit 1
}

