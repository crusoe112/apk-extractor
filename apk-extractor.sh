#!/bin/bash
BASE_PATH="`dirname $0`"

echo "Welcome to apk-extractor!"
echo ""

apkUrl=$1
echo "Google Play URL: $apkUrl"

downloadLink="`$BASE_PATH/utilities/get_apk_link.py \"$apkUrl\"`"
echo "APK Download Link: $downloadLink"
echo ""

echo "Downloading APK..."
wget "$downloadLink"

echo ""
apkFile="`echo ${downloadLink##*/}`"
echo "APK downloaded to $apkFile"
echo ""

jarFile=$apkFile.jar
echo "Created JAR File: $jarFile"
echo ""

echo .........apktool..........
cd $(dirname $apkFile)
apktool d -d -f "$apkFile"
echo ..........................
echo ""

echo .........dex2jar..........
d2j-dex2jar -f "$apkFile" -o "$jarFile"
echo ..........................
echo ""

echo .........jd-gui...........
java -jar "$BASE_PATH/utilities/jd-gui-1.6.6.jar" "$jarFile"
echo ..........................
echo ""

echo "Extraction Complete!"
