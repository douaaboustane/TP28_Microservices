# Script PowerShell pour gérer SonarQube en local
# Usage: .\sonarqube-setup.ps1 [start|stop|restart|status|logs]

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "setup")]
    [string]$Action = "status"
)

$ContainerName = "sonarqube"
$Port = 9000

function Setup-SonarQube {
    Write-Host "=== Configuration de SonarQube ===" -ForegroundColor Cyan
    
    # Créer les volumes
    Write-Host "Création des volumes Docker..." -ForegroundColor Yellow
    docker volume create sonarqube_data 2>$null
    docker volume create sonarqube_logs 2>$null
    docker volume create sonarqube_extensions 2>$null
    Write-Host "Volumes créés avec succès" -ForegroundColor Green
    
    # Vérifier si le conteneur existe déjà
    $existing = docker ps -a --filter "name=$ContainerName" --format "{{.Names}}"
    if ($existing -eq $ContainerName) {
        Write-Host "Le conteneur $ContainerName existe déjà" -ForegroundColor Yellow
        $response = Read-Host "Voulez-vous le supprimer et en créer un nouveau? (o/n)"
        if ($response -eq "o") {
            docker stop $ContainerName 2>$null
            docker rm $ContainerName 2>$null
        } else {
            Write-Host "Utilisation du conteneur existant" -ForegroundColor Green
            return
        }
    }
    
    # Lancer SonarQube
    Write-Host "Démarrage de SonarQube..." -ForegroundColor Yellow
    docker run -d --name $ContainerName -p ${Port}:9000 `
        -v sonarqube_data:/opt/sonarqube/data `
        -v sonarqube_logs:/opt/sonarqube/logs `
        -v sonarqube_extensions:/opt/sonarqube/extensions `
        sonarqube:lts-community
    
    Write-Host "SonarQube est en cours de démarrage..." -ForegroundColor Green
    Write-Host "Attendez quelques instants puis ouvrez: http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "Identifiants par défaut: admin / admin" -ForegroundColor Cyan
}

function Start-SonarQube {
    Write-Host "Démarrage de SonarQube..." -ForegroundColor Yellow
    docker start $ContainerName
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SonarQube démarré avec succès" -ForegroundColor Green
        Write-Host "URL: http://localhost:$Port" -ForegroundColor Cyan
    } else {
        Write-Host "Erreur lors du démarrage" -ForegroundColor Red
    }
}

function Stop-SonarQube {
    Write-Host "Arrêt de SonarQube..." -ForegroundColor Yellow
    docker stop $ContainerName
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SonarQube arrêté avec succès" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de l'arrêt" -ForegroundColor Red
    }
}

function Restart-SonarQube {
    Write-Host "Redémarrage de SonarQube..." -ForegroundColor Yellow
    docker restart $ContainerName
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SonarQube redémarré avec succès" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors du redémarrage" -ForegroundColor Red
    }
}

function Get-SonarQubeStatus {
    Write-Host "=== État de SonarQube ===" -ForegroundColor Cyan
    docker ps --filter "name=$ContainerName" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Vérifier l'accessibilité
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -UseBasicParsing -TimeoutSec 3
        Write-Host "`nSonarQube est accessible sur http://localhost:$Port" -ForegroundColor Green
    } catch {
        Write-Host "`nSonarQube n'est pas encore accessible (peut être en cours de démarrage)" -ForegroundColor Yellow
    }
}

function Show-SonarQubeLogs {
    Write-Host "=== Logs SonarQube ===" -ForegroundColor Cyan
    docker logs $ContainerName --tail 50 -f
}

# Exécuter l'action demandée
switch ($Action) {
    "setup" { Setup-SonarQube }
    "start" { Start-SonarQube }
    "stop" { Stop-SonarQube }
    "restart" { Restart-SonarQube }
    "status" { Get-SonarQubeStatus }
    "logs" { Show-SonarQubeLogs }
}

