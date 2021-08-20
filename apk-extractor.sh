#!/bin/bash
BASE_PATH="`dirname $0`"

echo "Welcome to apk-extractor!"
echo ""
echo "Usage:"
echo ".........................."
echo "./apk-extractor GOOGLE_PLAY_URL"
echo ".........................."
echo ""

apkUrl=$1
echo "Google Play URL: $apkUrl"

# Get the download link from Evozi
downloadLink="`$BASE_PATH/utilities/get_apk_link.py \"$apkUrl\"`"
echo "APK Download Link: $downloadLink"
echo ""

# Download the APK
echo "Downloading APK..."
wget "$downloadLink"

# Set the APK Filename
echo ""
apkFile="`echo ${downloadLink##*/}`"
echo "APK downloaded to $apkFile"
echo ""

# Create a JAR file for dex2jar
jarFile=$apkFile.jar
echo "Created JAR File: $jarFile"
echo ""

# Disassemble with akptook
echo .........apktool..........
cd $(dirname $apkFile)
apktool d -d -f "$apkFile"
echo ..........................
echo ""

# Convert DEX files to JAR file
echo .........dex2jar..........
d2j-dex2jar -f "$apkFile" -o "$jarFile"
echo ..........................
echo ""

# Open with JD-GUI
echo .........jd-gui...........
java -jar "$BASE_PATH/utilities/jd-gui-1.6.6.jar" "$jarFile"
echo ..........................
echo ""

echo "Extraction Complete!"
