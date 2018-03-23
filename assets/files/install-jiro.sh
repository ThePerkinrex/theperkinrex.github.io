p = `pwd`
if [ "`whoami`" != "root" ]; then
	echo "You're not running this as root, please enter the password to run as root"
	sudo echo ""
fi
version=`curl -sS https://api.github.com/repos/theperkinrex/jiro/releases/latest | grep -oiE "\"tag_name\": \"v\d+\.\d+\.\d+\"" | grep -oiE "v\d+\.\d+\.\d+"`

echo "Installing Jiro $version"
mkdir tmp
cd tmp
echo "Downloading Jiro launcher"
curl "https://raw.githubusercontent.com/ThePerkinrex/Jiro/$version/jiro.sh" -o jiro
chmod +x jiro
echo "Downloading Jiro.py"
mkdir source
curl "https://raw.githubusercontent.com/ThePerkinrex/Jiro/$version/source/Jiro.py" -o source/Jiro.py
echo "Downloading JRParser.py"
curl "https://raw.githubusercontent.com/ThePerkinrex/Jiro/$version/source/JRParser.py" -o source/JRParser.py
echo "Downloading Tokens.py"
curl "https://raw.githubusercontent.com/ThePerkinrex/Jiro/$version/source/Tokens.py" -o source/Tokens.py
echo "Downloading Utils.py"
curl "https://raw.githubusercontent.com/ThePerkinrex/Jiro/$version/source/Utils.py" -o source/Utils.py
echo ""
echo ""
# echo "Installing Jiro into /usr/local/jiro/bin"
# echo "It may ask for permission to copy files into there"
cd ..
if [ ! -d "/usr/local/jiro"  ]; then
	echo "Creating the directory"
	sudo mkdir -p /usr/local/jiro/bin
	echo "Adding it to the path"
	echo "# Jiro path" >> ~/.bash_profile
	echo "export PATH=\"/usr/local/jiro/bin:\$PATH\"" >> ~/.bash_profile
else
	echo "Updating Jiro"
fi
echo "Copying"
sudo cp -a tmp/* /usr/local/jiro/bin
rm -r tmp
#echo "Reloading bash"
#source ~/.bash_profile
#if [ $? -eq 0 ]; then
#    echo "Reloading with source gave an error, trying with bash-it's reload"
#    reload
#fi
echo "Finishing the installation"
sudo jiro &>/dev/null || (echo "For the first-time installation you must now execute:"; echo "source ~/.bash_profile"; echo "sudo jiro &>/dev/null")
