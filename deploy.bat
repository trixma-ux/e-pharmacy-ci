@echo off
echo ========================================================
echo   PHARMAFLOW - BUILD WEB ET DEPLOIEMENT GITHUB PAGES
echo ========================================================
echo.

cd pharmaflow

echo [1/4] Clean et Recuperation des packages...
call flutter clean
call flutter pub get

echo [2/4] Compilation en mode Web Release (base-href /e-pharmacy-ci/)...
call flutter build web --release --base-href "/e-pharmacy-ci/"

if %ERRORLEVEL% neq 0 (
    echo ERREUR: flutter build web a echoue.
    pause & exit /b 1
)

echo [3/4] Preparation du dossier de deploiement...
cd build\web

echo [4/4] Deploiement sur la branche gh-pages...
git init
git remote add origin https://github.com/trixma-ux/e-pharmacy-ci.git
git checkout -b gh-pages
git add -A
git commit -m "deploy: release build to github pages"
git push -f origin gh-pages

if %ERRORLEVEL% neq 0 (
    echo ERREUR: Le deploiement sur gh-pages a echoue.
    pause & exit /b 1
)

echo ========================================================
echo  DEPLOIEMENT REUSSI ! Le site est en cours de publication sur :
echo  https://trixma-ux.github.io/e-pharmacy-ci/
echo ========================================================
pause
