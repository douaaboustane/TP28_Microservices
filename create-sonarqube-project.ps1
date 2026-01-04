# Script PowerShell pour créer un projet SonarQube via l'API REST
# Usage: .\create-sonarqube-project.ps1 -ProjectName "Student_class" [-ProjectKey "Student_class"] [-Username "admin"] [-Password "admin"] [-Port 9000]

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "Student_class",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "admin",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "admin",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9000,
    
    [Parameter(Mandatory=$false)]
    [string]$HostUrl = "http://localhost"
)

$SonarUrl = "$HostUrl`:$Port"
$ApiUrl = "$SonarUrl/api"

# Si ProjectKey n'est pas fourni, utiliser ProjectName
if ([string]::IsNullOrWhiteSpace($ProjectKey)) {
    $ProjectKey = $ProjectName
}

Write-Host "=== Création d'un projet SonarQube ===" -ForegroundColor Cyan
Write-Host "Project Name: $ProjectName" -ForegroundColor Yellow
Write-Host "Project Key: $ProjectKey" -ForegroundColor Yellow
Write-Host "SonarQube URL: $SonarUrl" -ForegroundColor Yellow

# Vérifier que SonarQube est accessible
Write-Host "`nVérification de l'accessibilité de SonarQube..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $SonarUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "SonarQube est accessible" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: SonarQube n'est pas accessible sur $SonarUrl" -ForegroundColor Red
    Write-Host "Vérifiez que SonarQube est démarré: .\sonarqube-setup.ps1 status" -ForegroundColor Yellow
    exit 1
}

# Créer les credentials pour l'authentification Basic
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)
$pair = "${Username}:${Password}"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{
    "Authorization" = "Basic $encodedCreds"
}

# Vérifier si le projet existe déjà
Write-Host "`nVérification de l'existence du projet..." -ForegroundColor Cyan
try {
    $encodedKey = [System.Uri]::EscapeDataString($ProjectKey)
    $checkUrl = "$ApiUrl/projects/search?projects=$encodedKey"
    $checkResponse = Invoke-RestMethod -Uri $checkUrl -Headers $headers -Method Get -ErrorAction Stop
    if ($checkResponse.components -and $checkResponse.components.Count -gt 0) {
        Write-Host "Le projet '$ProjectKey' existe déjà dans SonarQube" -ForegroundColor Yellow
        Write-Host "URL du projet: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
        exit 0
    }
} catch {
    # Si erreur 404 ou autre, on continue (projet n'existe pas)
    Write-Host "Le projet n'existe pas encore, création en cours..." -ForegroundColor Green
}

# Créer le projet via l'API REST
Write-Host "`nCréation du projet via l'API REST..." -ForegroundColor Cyan

# Construire le body en format application/x-www-form-urlencoded
$encodedName = [System.Uri]::EscapeDataString($ProjectName)
$encodedProject = [System.Uri]::EscapeDataString($ProjectKey)
$body = "name=$encodedName&project=$encodedProject"

try {
    $createUrl = "$ApiUrl/projects/create"
    $response = Invoke-RestMethod -Uri $createUrl -Headers $headers -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    
    Write-Host "`n=== Projet créé avec succès ===" -ForegroundColor Green
    Write-Host "Project Key: $($response.project.key)" -ForegroundColor Yellow
    Write-Host "Project Name: $($response.project.name)" -ForegroundColor Yellow
    Write-Host "`nURL du projet: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Cyan
    Write-Host "`nProchaines étapes:" -ForegroundColor Cyan
    Write-Host "1. Ouvrez le projet dans SonarQube: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor White
    Write-Host "2. Générez un token pour l'analyse (My Account > Security > Generate Token)" -ForegroundColor White
    Write-Host "3. Utilisez le script analyze-maven.ps1 pour analyser votre projet" -ForegroundColor White
    
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "`n=== Erreur lors de la création du projet ===" -ForegroundColor Red
    
    # Essayer d'extraire le message d'erreur de la réponse
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        try {
            $errorJson = $responseBody | ConvertFrom-Json
            if ($errorJson.errors) {
                $errorMessage = $errorJson.errors[0].msg
            }
        } catch {
            # Si ce n'est pas du JSON, utiliser le message original
        }
    }
    
    Write-Host "Message d'erreur: $errorMessage" -ForegroundColor Red
    
    if ($errorMessage -like "*already exists*" -or $errorMessage -like "*déjà existant*") {
        Write-Host "`nLe projet existe déjà. URL: $SonarUrl/dashboard?id=$ProjectKey" -ForegroundColor Yellow
    } elseif ($errorMessage -like "*401*" -or $errorMessage -like "*Unauthorized*") {
        Write-Host "`nErreur d'authentification. Vérifiez vos identifiants." -ForegroundColor Yellow
        Write-Host "Si vous avez changé le mot de passe admin, utilisez:" -ForegroundColor Yellow
        Write-Host ".\create-sonarqube-project.ps1 -ProjectName `"$ProjectName`" -Password `"VOTRE_MOT_DE_PASSE`"" -ForegroundColor White
    }
    
    exit 1
}

