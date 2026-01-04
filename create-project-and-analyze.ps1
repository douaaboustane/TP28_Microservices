# Script pour créer le projet dans SonarQube et lancer l'analyse
# Ce script ouvre SonarQube dans le navigateur et guide la création du projet

$ProjectKey = "StudentClass"
$ProjectName = "StudentClass"
$SonarUrl = "http://localhost:9000"

Write-Host "=== Création du projet SonarQube et Analyse ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectName (Key: $ProjectKey)" -ForegroundColor Yellow

# Vérifier que SonarQube est accessible
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube est accessible" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: SonarQube n'est pas accessible" -ForegroundColor Red
    Write-Host "Démarrez SonarQube: .\sonarqube-setup.ps1 start" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== Instructions pour créer le projet ===" -ForegroundColor Cyan
Write-Host "1. Le navigateur va s'ouvrir sur la page de connexion SonarQube" -ForegroundColor White
Write-Host "2. Connectez-vous avec: admin / admin" -ForegroundColor White
Write-Host "3. Si c'est la première connexion, changez le mot de passe" -ForegroundColor Yellow
Write-Host "4. Allez dans Projects > Create Project > Manually" -ForegroundColor White
Write-Host "5. Renseignez:" -ForegroundColor White
Write-Host "   - Project display name: $ProjectName" -ForegroundColor Gray
Write-Host "   - Project key: $ProjectKey" -ForegroundColor Gray
Write-Host "6. Choisissez 'Locally' puis 'Maven'" -ForegroundColor White
Write-Host "7. Générez un token et copiez-le" -ForegroundColor White
Write-Host "`nAppuyez sur Entrée une fois le projet créé et le token généré..." -ForegroundColor Yellow

# Ouvrir SonarQube dans le navigateur
Start-Process $SonarUrl

# Attendre que l'utilisateur appuie sur Entrée
Read-Host "Appuyez sur Entrée pour continuer"

# Demander le token
Write-Host "`n=== Token SonarQube ===" -ForegroundColor Cyan
$Token = Read-Host "Collez le token généré"

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "ERREUR: Token requis pour l'analyse" -ForegroundColor Red
    exit 1
}

# Lancer l'analyse
Write-Host "`n=== Lancement de l'analyse ===" -ForegroundColor Cyan
Write-Host "Project Key: $ProjectKey" -ForegroundColor Yellow
Write-Host "SonarQube: $SonarUrl" -ForegroundColor Yellow

mvn clean verify sonar:sonar `
    -Dsonar.projectKey=$ProjectKey `
    -Dsonar.host.url=$SonarUrl `
    -Dsonar.login=$Token

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Analyse réussie ===" -ForegroundColor Green
    Write-Host "Résultats disponibles sur: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
    Write-Host "`nOuverture du dashboard..." -ForegroundColor Yellow
    Start-Process "$SonarUrl/dashboard?id=$ProjectKey"
} else {
    Write-Host "`n=== Erreur lors de l'analyse ===" -ForegroundColor Red
    exit 1
}

