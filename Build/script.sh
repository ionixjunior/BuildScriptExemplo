#!/bin/bash

# Funções para log
inicio()
{
    echo "##[section]Starting: $1"
}

fim()
{
    echo "##[section]Finishing: $1"
}



# Verificando se SOLUTION_DIR foi informado
inicio "Verificando SOLUTION_DIR"

if [ -n "$1" ]
then
    SOLUTION_DIR=$1
else
    SOLUTION_DIR=$APPCENTER_SOURCE_DIRECTORY
fi

echo "SOLUTION_DIR : $SOLUTION_DIR"
fim "Verificando SOLUTION_DIR"



# Criando variáveis dos arquivos
inicio "Criando variáveis"

MANIFEST=$SOLUTION_DIR/Droid/Properties/AndroidManifest.xml
INFO_PLIST=$SOLUTION_DIR/iOS/Info.plist
ENTITLEMENTS_PLIST=$SOLUTION_DIR/iOS/Entitlements.plist
APP_CONFIG=$SOLUTION_DIR/Core/AppConfig.cs
APP_XAML=$SOLUTION_DIR/Core/App.xaml
APP_INI=$SOLUTION_DIR/Build/app.ini

echo "MANIFEST           : $MANIFEST"
echo "INFO_PLIST         : $INFO_PLIST"
echo "ENTITLEMENTS_PLIST : $ENTITLEMENTS_PLIST"
echo "APP_CONFIG         : $APP_CONFIG"
echo "APP_XAML           : $APP_XAML"
echo "APP_INI            : $APP_INI"
fim "Criando variáveis"



# Verificando se app.ini existe

inicio "Verificando variáveis de ambiente"
if [ -e "$APP_INI" ]
then
    CLIENTE=$(cat $APP_INI | grep "CLIENTE = " | awk '{print $3}')
    API_URL=$(cat $APP_INI | grep "API_URL = " | awk '{print $3}')
    VERSION_NAME=$(cat $APP_INI | grep "VERSION_NAME = " | awk '{print $3}')
    APP_NAME=$(cat $APP_INI | grep "APP_NAME = " | awk '{{out=$3; for(i=4;i<=NF;i++){out=out" "$i}; print out}}')
    PACKAGE=$(cat $APP_INI | grep "PACKAGE = " | awk '{print $3}')
    APS_ENVIRONMENT=$(cat $APP_INI | grep "APS_ENVIRONMENT = " | awk '{print $3}')
    PRIMARY_COLOR=$(cat $APP_INI | grep "PRIMARY_COLOR = " | awk '{print $3}')  

    echo "Variáveis de ambiente carregadas do app.ini"
    echo "CLIENTE         : $CLIENTE"
    echo "API_URL         : $API_URL"
    echo "VERSION_NAME    : $VERSION_NAME"
    echo "APP_NAME        : $APP_NAME"
    echo "PACKAGE         : $PACKAGE"
    echo "APS_ENVIRONMENT : $APS_ENVIRONMENT"
    echo "PRIMARY_COLOR   : $PRIMARY_COLOR"
else
    echo "Variáveis de ambiente carregadas do App Center"
    echo "CLIENTE         : $CLIENTE"
    echo "API_URL         : $API_URL"
    echo "VERSION_NAME    : $VERSION_NAME"
    echo "APP_NAME        : $APP_NAME"
    echo "PACKAGE         : $PACKAGE"
    echo "APS_ENVIRONMENT : $APS_ENVIRONMENT"
    echo "PRIMARY_COLOR   : $PRIMARY_COLOR"
fi

fim "Verificando variáveis de ambiente"


# Copiar imagens
inicio "Copiar arquivos"
cp $SOLUTION_DIR/Build/Clientes/$CLIENTE/Droid/Resources/drawable/*.png \
$SOLUTION_DIR/Droid/Resources/drawable/

cp $SOLUTION_DIR/Build/Clientes/$CLIENTE/Droid/Resources/drawable-hdpi/*.png \
$SOLUTION_DIR/Droid/Resources/drawable-hdpi/

cp $SOLUTION_DIR/Build/Clientes/$CLIENTE/iOS/Assets.xcassets/AppIcon.appiconset/*.png \
$SOLUTION_DIR/iOS/Assets.xcassets/AppIcon.appiconset/

cp $SOLUTION_DIR/Build/Clientes/$CLIENTE/iOS/Assets.xcassets/LaunchImage.launchimage/*.png  \
$SOLUTION_DIR/iOS/Assets.xcassets/LaunchImage.launchimage/

cp $SOLUTION_DIR/Build/Clientes/$CLIENTE/iOS/Resources/*.png \
$SOLUTION_DIR/iOS/Resources/
fim "Copiar arquivos"


# Manifesto Android
inicio "Alterar arquivo manifesto Android"
sed -i '' 's/versionName="[0-9.]*"/versionName="'$VERSION_NAME'"/' $MANIFEST
sed -i '' 's/android:label="[a-zA-Zà-úÀ-Ú0-9 ]*"/android:label="'"$APP_NAME"'"/' $MANIFEST
sed -i '' 's/package="[a-z.]*"/package="'$PACKAGE'"/' $MANIFEST

echo "Resultado do arquivo:"
echo ""
cat $MANIFEST
echo ""
fim "Alterar arquivo manifesto Android"


# plist iOS
inicio "Alterar arquivos plist iOS"
plutil -replace CFBundleIdentifier -string $PACKAGE $INFO_PLIST
plutil -replace CFBundleName -string "$APP_NAME" $INFO_PLIST
plutil -replace CFBundleDisplayName -string "$APP_NAME" $INFO_PLIST
plutil -replace CFBundleShortVersionString -string $VERSION_NAME $INFO_PLIST
plutil -replace aps-environment -string $APS_ENVIRONMENT $ENTITLEMENTS_PLIST

echo "Resultado dos arquivos:"
echo ""
cat $INFO_PLIST
echo ""
cat $ENTITLEMENTS_PLIST
echo ""
fim "Alterar arquivos plist iOS"


# Constantes
inicio "Alterar constantes"
sed -i '' 's#ApiUrl = "[a-z:./]*"#ApiUrl = "'$API_URL'"#' $APP_CONFIG

echo "Resultado do arquivo:"
echo ""
cat $APP_CONFIG
echo ""
fim "Alterar constantes"


# Resource dictionary
inicio "Alterar resource dictionary"
sed -i '' 's/"PrimaryColor">[a-zA-Z0-9#]*</"PrimaryColor">'$PRIMARY_COLOR'</' $APP_XAML

echo "Resultado do arquivo:"
echo ""
cat $APP_XAML
echo ""
fim "Alterar resource dictionary"
