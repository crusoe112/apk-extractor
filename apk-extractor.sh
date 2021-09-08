#!/bin/bash
BASE_PATH="`dirname $0`"
analyzer="jd-gui"
apkSource=""

function usage {
        echo "Usage: $(basename $0) [-a ANALYZER] -s APK_SOURCE" 2>&1
        echo '   -a ANALYZER            jd-gui|jadx'
        echo '   -s APK_SOURCE  GOOGLE_PLAY_URL|APP_ID|APK_FILE'
}
print_banner () {
        cat <<- "EOF"
            _    ____  _  __   __  ___                  _    
           / \  |  _ \| |/ /   \ \/ / |_ _ __ __ _  ___| |_ 
          / _ \ | |_) | ' /_____\  /| __| '__/ _` |/ __| __|
         / ___ \|  __/| . \_____/  \| |_| | | (_| | (__| |_ 
        /_/   \_\_|   |_|\_\   /_/\_\\__|_|  \__,_|\___|\__|
                                      Created by Marc Bohler
        EOF
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
        apkSource=$1
        if [[ $apkSource == "http"* ]]; then
                downloadLink="$($BASE_PATH/utilities/get_apk_link.py --mode url $apkSource)"
                downloadAPK "$downloadLink"
                echo "$(urlToFilename $downloadLink)"
        elif [[ $apkSource == *".apk"* ]]; then
                echo "$apkSource"
        else
                downloadLink="$($BASE_PATH/utilities/get_apk_link.py --mode id $apkSource)"
                downloadAPK "$downloadLink"
                echo "$(urlToFilename $downloadLink)"
        fi
}

jdguiPath () {
        apkFile="$1"

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
}

jadxPath () {
        apkFile="$1"
        full_path="$(pwd)/$apkFile"

        # Open with JADX
        echo ..........jadx..........
        jadx-gui "$full_path"
        echo ........................
        echo ""
}

# Main
print_banner

# Parse Arguments
while getopts h:a:s: flag
do
        case "${flag}" in
                h) usage
                   exit;;
                a) analyzer=${OPTARG};;
                s) apkSource=${OPTARG};;
        esac
done
if [ "$apkSource" == "" ]; then
        usage
        exit -1
fi
if [ "$analyzer" != "jd-gui" ] && [ "$analyzer" != "jadx" ]; then
        usage
        exit -1
fi

# Extract
retrievingBanner="Retrieving APK from source: $apkSource"
rbLen=${#retrievingBanner}
printf '%.0s-' $(seq $rbLen); echo ""
echo "$retrievingBanner"
printf '%.0s-' $(seq $rbLen); echo ""
echo ""
apkFile=$(getAPKLink "$apkSource")
printf '%.0s-' $(seq $rbLen); echo ""
echo ""
extractingBanner="Performing extraction of: $apkFile"
ebLen=${#extractingBanner}
printf '%.0s-' $(seq $ebLen); echo ""
echo "$extractingBanner"
printf '%.0s-' $(seq $ebLen); echo ""

# Choose analyzer path
if [ "$analyzer" == "jadx" ]; then
        echo ""
        echo "Extracting with: JADX"
        jadxPath "$apkFile"
elif [ "$analyzer" == "jd-gui" ]; then
        echo ""
        echo "Extracting with: JD-GUI"
        jdguiPath "$apkFile"
fi

printf '%.0s-' $(seq $ebLen); echo ""
echo "Extraction Complete!"