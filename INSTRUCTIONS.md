# Instructions pour analyser le projet StudentClass avec SonarQube

## Étape 1 : Vérifier que SonarQube est démarré

```powershell
.\sonarqube-setup.ps1 status
```

Si SonarQube n'est pas démarré :
```powershell
.\sonarqube-setup.ps1 start
```

Attendez quelques instants que SonarQube soit prêt (accessible sur http://localhost:9000)

## Étape 2 : Créer le projet dans SonarQube

1. Ouvrez votre navigateur et allez sur : **http://localhost:9000**
2. Connectez-vous avec :
   - **Login** : `admin`
   - **Password** : `admin`
3. Si c'est la première connexion, SonarQube vous demandera de changer le mot de passe
4. Allez dans **Projects** (en haut de la page)
5. Cliquez sur **Create Project** (en haut à droite)
6. Choisissez **Manually**
7. Renseignez :
   - **Project display name** : `StudentClass`
   - **Project key** : `StudentClass`
8. Cliquez sur **Set Up**

## Étape 3 : Générer un token

1. Dans la page qui s'affiche, choisissez **Locally**
2. Sélectionnez **Maven**
3. Dans la section "Generate a token", renseignez :
   - **Token name** : `Analyze StudentClass`
   - **Expiration** : `30 days` (ou plus)
4. Cliquez sur **Generate**
5. **COPIEZ LE TOKEN** (vous ne pourrez plus le voir après !)

## Étape 4 : Lancer l'analyse

Une fois le token copié, exécutez cette commande dans PowerShell (remplacez `VOTRE_TOKEN` par le token copié) :

```powershell
.\analyze-maven.ps1 -ProjectKey "StudentClass" -Token "VOTRE_TOKEN"
```

Ou directement avec Maven :

```powershell
mvn clean verify sonar:sonar `
  -Dsonar.projectKey=StudentClass `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.login=VOTRE_TOKEN
```

## Étape 5 : Consulter les résultats

Une fois l'analyse terminée, ouvrez dans votre navigateur :
**http://localhost:9000/dashboard?id=StudentClass**

Vous verrez :
- **Overview** : Résumé et Quality Gate
- **Issues** : Liste des problèmes détectés (Bugs, Code Smells, etc.)
- **Measures** : Métriques (couverture, duplication, complexité)
- **Code** : Code annoté avec les problèmes

## Dépannage

### Erreur 401 Unauthorized
- Vérifiez que le token est correct
- Régénérez un nouveau token dans SonarQube

### Connection refused
- Vérifiez que SonarQube est démarré : `.\sonarqube-setup.ps1 status`
- Vérifiez que le port 9000 n'est pas occupé

### Projet introuvable
- Vérifiez que le `projectKey` dans la commande Maven correspond exactement à celui créé dans SonarQube
- Le projectKey est sensible à la casse : `StudentClass` (pas `studentclass`)

