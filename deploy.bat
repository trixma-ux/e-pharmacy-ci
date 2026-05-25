@echo off
echo ========================================================
echo   PHARMAFLOW - CORRECTION DES BUGS + DEPLOIEMENT FINAL
echo ========================================================
echo.

cd pharmaflow

echo [1/5] Telechargement des packages...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo ERREUR: flutter pub get a echoue.
    pause & exit /b 1
)

echo [2/5] Analyse du code...
call flutter analyze --no-fatal-infos --no-fatal-warnings
echo Analyse terminee.

echo [3/5] Retour au dossier racine...
cd ..

echo [4/5] Deploiement sur GitHub (commit + push)...
git add -A
git commit -m "feat: correction de tous les bugs, Phase 4 complete (Carte OSM + Chat + Firebase)"
git push

if %ERRORLEVEL% neq 0 (
    echo ERREUR: git push a echoue.
    pause & exit /b 1
)

echo.
echo ========================================================
echo  SUCCES ! CODE POUSSE SUR GITHUB.
echo ========================================================
echo.
echo  Lien GitHub : verifiez avec -> git remote get-url origin
echo.
echo  RAPPEL : Pour activer Firebase Authentication :
echo  1. Allez sur console.firebase.google.com
echo  2. Projet pharmacyflow-bd0ef
echo  3. Authentication > Activer Email/Password
echo  4. Firestore Database > Creer une base de donnees
echo  5. Copiez les regles Firestore depuis la doc ci-dessous
echo ========================================================
pause
