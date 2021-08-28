# apk-extractor
Automates the process of downloading and extracting APK's for analysis of decompiled Android apps

## Installation
Run the following commands to install (requires sudo privileges):
```bash
chmod +x setup.sh
./setup.sh
```
## Usage
Execute the tool with the Google play URL, App ID, or APK file of the desired Android app
1. URL:
```bash
./apk-extractor https://play.google.com/store/apps/details?id=com.example&hl=en&gl=US
```
2. APP ID:
```bash
./apk-extractor com.example
```
3. APK File:
```bash
./apk-extractor example.apk
```
