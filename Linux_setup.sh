#!/bin/bash
OR='\e[38;5;202m'
GR='\e[32m'
NL='\e[0m'
WH='\e[97m'
BL='\e[34m'


echo -e "
${OR} ██████╗██╗   ██╗██████╗ ██████╗ ██████╗ ███████╗███████╗███████╗████████╗${NL}
${OR}██╔════╝╚██╗ ██╔╝██╔══██╗╚════██╗██╔${BL}══${NL}${OR}██╗╚══███╔╝██╔════╝██╔════╝╚══██╔══╝${NL}
${WH}██║      ╚████╔╝ ██████╔╝ █████╔╝${BL}██████╔╝${NL}${WH}  ███╔╝ █████╗  ███████╗   ██║   ${NL}
${WH}██║       ╚██╔╝  ██╔══██╗ ╚═══██╗${BL}██╔══██╗${NL}${WH} ███╔╝  ██╔══╝  ╚════██║   ██║   ${NL}
${GR}╚██████╗   ██║   ██████╔╝██████╔╝██║${BL}  █${NL}${GR}█║███████╗███████╗███████║   ██║   ${NL}
${GR} ╚═════╝   ╚═╝   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝   ${NL}
"
echo "  This script is made by CyberZest and improved by mytricker0
"

# Check if Java JDK 21 is installed
if ! command -v javac >/dev/null 2>&1; then
    echo "Java JDK 21 is not installed, installing"
    mkdir -p /usr/local/java
    mkdir -p /usr/local/java/jdk21
    curl -L https://download.oracle.com/java/21/archive/jdk-21.0.3_linux-x64_bin.tar.gz -o jdk21.tar.gz
    tar -xf jdk21.tar.gz -C /usr/local/java/jdk21 --strip-components=1
    rm jdk21.tar.gz
    echo "export JAVA_HOME=/usr/local/java/jdk21" | sudo tee -a /etc/environment
    echo "export PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/environment   #by @ricardev2023
    sudo update-alternatives --install /usr/bin/java java /usr/local/java/jdk21/bin/java 1
    sudo update-alternatives --install /usr/bin/javac javac /usr/local/java/jdk21/bin/javac 1
    source /etc/profile
    echo "Java JDK 21 downloaded and installed successfully"
fi

# Check if Java JRE 8 is installed
if ! command -v java >/dev/null 2>&1; then
    jre8_url=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247938_0ae14417abb444ebb02b9815e2103550
    sudo mkdir -p /usr/local/java/jre8
    sudo curl -L -o /usr/local/java/jre8/jre8.tar.gz $jre8_url
    sudo tar -xzf /usr/local/java/jre8/jre8.tar.gz -C /usr/local/java/jre8
    sudo rm /usr/local/java/jre8/jre8.tar.gz
    sudo update-alternatives --install /usr/bin/java java /usr/local/java/jre8/jre1.8.0_361/bin/java 1
    sudo update-alternatives --install /usr/bin/javac javac /usr/local/java/jre8/jre1.8.0_361/bin/javac 1
    sudo update-alternatives --set java /usr/local/java/jre8/jre1.8.0_361/bin/java 1
    sudo update-alternatives --set javac /usr/local/java/jre8/jre1.8.0_361/bin/javac 1
    echo "Java JRE 8 downloaded and installed successfully"
fi


if [[ $EUID -ne 0 ]]; then
    echo "Execute Command as Root User"
    exit 1
fi



# Download Burp Suite Profesional Latet Version
echo 'Downloading Burp Suite Professional ....'
mkdir -p /usr/share/burpsuite
cp loader.jar /usr/share/burpsuite/
cp burp_suite.ico /usr/share/burpsuite/
rm Windows_setup.ps1
rm -rf .git
cd /usr/share/burpsuite/
rm burpsuite.jar
html=$(curl -s https://portswigger.net/burp/releases)
version=$(echo $html | grep -Po '(?<=/burp/releases/professional-community-)[0-9]+\-[0-9]+\-[0-9]+' | head -n 1)
Link="https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar"
echo $version
wget "$Link" -O burpsuite_pro_v$version.jar --quiet --show-progress
sleep 2

# Execute Burp Suite Professional with Keyloader
echo 'Executing Burp Suite Professional with Keyloader'
echo "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/loader.jar -noverify -jar $(pwd)/burpsuite_pro_v$version.jar &" > burpsuite
chmod +x burpsuite
cp burpsuite /bin/burpsuite

# execute Keygenerator
echo 'Starting Keygenerator'
(java -jar loader.jar) &
sleep 3s
(./burpsuite)


# Additional setup for desktop entry and PolicyKit policy
# Create the BurpSuiteProWrapper.sh script
cat > /usr/bin/BurpSuiteProWrapper.sh << EOF
#!/bin/bash
# Navigate to the Burp Suite installation directory
cd /usr/share/burpsuite/
/bin/burpsuite
EOF

# Make the wrapper script executable
chmod +x /usr/bin/BurpSuiteProWrapper.sh

# Create the desktop entry for Burp Suite Pro
cat > /usr/share/applications/burpsuite_pro.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Burp Suite Pro
Comment=Burp Suite Pro Cracked
Exec=pkexec /usr/bin/BurpSuiteProWrapper.sh
Icon=$(pwd)/burp_suite.ico
Terminal=false
Categories=Utility;
EOF

# Update the icon path according to the user's actual icon location

# Create the PolicyKit file
cat > /usr/share/polkit-1/actions/com.yourcompany.burpsuite.policy << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN" "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
    <action id="com.yourcompany.burpsuite">
        <description>Run Burp Suite as root</description>
        <message>Authentication is required to run Burp Suite as root</message>
        <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/BurpSuiteProWrapper.sh</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
    </action>
</policyconfig>
EOF

echo "Setup complete. You can find Burp Suite Pro in your applications menu."

