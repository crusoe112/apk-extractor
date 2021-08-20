# Make executable
chmod +x apk-extractor.sh
chmod +x ./utilities/get_apk_link.py

# Install apt tools
sudo apt install -y apktool
sudo apt install -y dex2jar

# Install JD-GUI
wget -O ./utilities/jd-gui-1.6.6.jar https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar
