#!/bin/bash
BASE_PATH="`dirname $0`"

print_banner () {
        echo "Welcome to apk-extractor!"
        echo ""
        echo "Usage:"
        echo ".........................."
        echo "./apk-extractor GOOGLE_PLAY_URL|APP_ID|APK_FILE"
        echo ".........................."
        echo ""
}

downloadAPK () {
        wget "$1"
}

urlToFilename () {
        downloadLink=$1
        apkFile="$(echo ${downloadLink##*/})"
        echo "$apkFile"
}

getAPKLink () {
        if [[ $1 == "http"* ]]; then
                downloadLink="$($BASE_PATH/utilities/get_apk_link.py --mode url \"$1\")"
                downloadAPK "$downloadLink"
                echo "$(urlToFilename $downloadLink)"
        elif [[ $1 == *".apk"* ]]; then
                echo "$1"
        else
                downloadLink="$($BASE_PATH/utilities/get_apk_link.py --mode id \"$1\")"
                downloadAPK "$downloadLink"
                echo "$(urlToFilename $downloadLink)"
        fi
}

print_banner
apkUrl=$1
apkFile=$(getAPKLink $apkUrl)

echo ""
echo "APK File: $apkFile"

# Create a JAR file for dex2jar
jarFile=$apkFile.jar
echo "Created JAR File: $jarFile"
echo ""

# Disassemble with apktool
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
