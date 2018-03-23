
if [ "`whoami`" != "root" ]; then
	echo "You're not running this as root, please enter the password to run as root"
	sudo echo ""
fi
echo "Removing it from path"
sed -i '' '/# [Jj]iro [Ppath]/d' ~/.bash_profile
sed -i '' '/export PATH="\/usr\/local\/jiro\/bin:\$PATH"/d' ~/.bash_profile
echo "Removing /usr/local/jiro"
sudo rm -r /usr/local/jiro
echo "Done, now reload bash by executing:"
echo "source ~/.bash_profile"
