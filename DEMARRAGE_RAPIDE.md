# 🚀 Démarrage Rapide - Analyse SonarQube

## ✅ État actuel

- ✅ SonarQube est configuré et accessible sur http://localhost:9000
- ✅ Projet Maven `StudentClass` copié dans ce répertoire
- ✅ Scripts PowerShell créés pour faciliter l'analyse

## 📋 Étapes à suivre

### 1. Ouvrir SonarQube
```powershell
.\open-sonarqube.ps1
```

### 2. Créer le projet dans SonarQube

Dans le navigateur qui s'ouvre :

1. **Connectez-vous** avec `admin` / `admin`
2. Si demandé, **changez le mot de passe**
3. Allez dans **Projects** → **Create Project**
4. Choisissez **Manually**
5. Renseignez :
   - **Project display name** : `StudentClass`
   - **Project key** : `StudentClass`
6. Cliquez sur **Set Up**
7. Choisissez **Locally** → **Maven**
8. **Générez un token** (ex: `Analyze StudentClass`)
9. **COPIEZ LE TOKEN** ⚠️ (vous ne pourrez plus le voir après !)

### 3. Lancer l'analyse

Une fois le token copié, exécutez :

```powershell
.\quick-analyze.ps1 -Token "VOTRE_TOKEN_ICI"
```

Le script va :
- Compiler le projet Maven
- Lancer les tests
- Envoyer l'analyse à SonarQube
- Ouvrir automatiquement les résultats dans le navigateur

## 📊 Consulter les résultats

Les résultats seront disponibles sur :
**http://localhost:9000/dashboard?id=StudentClass**

Sections importantes :
- **Overview** : Résumé et Quality Gate
- **Issues** : Bugs, Code Smells, Vulnérabilités
- **Measures** : Métriques (couverture, duplication)
- **Code** : Code annoté avec les problèmes

## 🛠️ Scripts disponibles

| Script | Description |
|--------|-------------|
| `sonarqube-setup.ps1` | Gérer SonarQube (start/stop/status/logs) |
| `open-sonarqube.ps1` | Ouvrir SonarQube dans le navigateur |
| `quick-analyze.ps1` | Lancer l'analyse (nécessite un token) |
| `analyze-maven.ps1` | Analyse générique avec paramètres |

## ❓ Besoin d'aide ?

Consultez `INSTRUCTIONS.md` pour le guide détaillé.

