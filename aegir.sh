#!/bin/sh
# Written by Brian Gilbert @BrianGilbert_ https://github.com/BrianGilbert
# of Realityloop @Realityloop http://realitylop.com/
# I'm by no means a bash scripter, please submit pull requests/issues for improvements. :)

# Set some variables for username installing aegir and the OS X version
USERNAME=`ps -o user= $(ps -o ppid= $PPID)`
OSX=`sw_vers -productVersion`


# Make sure that the script wasn't run as root.
if [ $USERNAME = "root" ] ; then
  printf "This script needs to be run via sudo, not as root. exiting.\n"
  exit
fi


# Check Aegir isn't already installed.
if [ -e "/var/aegir/config/includes/global.inc" ] ; then
  printf "You already have aegir installed.. exiting.\n"
  exit # Remove this line when uninstall block below is fixed.
  # Possibly I'll allow reinstallations in the future..
  #
  # printf "Should I remove it and do a clean install? [Y/n]\n"
  # read CLEAN
  # if [ $CLEAN != n -o $CLEAN != N ] ; then
  #   printf "There is no turning back..\nThis will unusinstall aegir and all related homebrew compononets before running a clean install, are you sure? [Y/n]\n"
  #   read FORSURE
  #   if [ $FORSURE != n -o $FORSURE != N ] ; then
  #     printf "Don't say I didn't warn you, cleaning everything before running clean install..\n"

  #     printf "Stopping and deleting any services that are already installed..\n"
  #     if [ -e "/Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist" ] ; then
  #       launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  #       rm /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  #     fi

  #     if [ -e "/Library/LaunchDaemons/homebrew.mxcl.nginx.plist" ] ; then
  #     sudo -u $USERNAME launchctl unload -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
  #     sudo -u $USERNAME rm /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
  #     fi

  #     if [ -e "~/Library/LaunchAgents/homebrew.mxcl.mariadb.plist" ] ; then
  #     sudo -u $USERNAME launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
  #     sudo -u $USERNAME rm ~/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
  #     fi

  #     if [ -e "~/Library/LaunchAgents/homebrew-php.josegonzalez.php53.plist" ] ; then
  #     sudo -u $USERNAME launchctl unload -w ~/Library/LaunchAgents/homebrew-php.josegonzalez.php53.plist
  #     sudo -u $USERNAME rm ~/Library/LaunchAgents/homebrew-php.josegonzalez.php53.plist
  #     fi
  #     printf "Removing Aegir folder..\n"
  #     rm -rf /var/aegir
  #     printf "Uninstalling related brews..\n"
  #     sudo -u $USERNAME brew uninstall php53-uploadprogress
  #     sudo -u $USERNAME brew uninstall php53-xdebug
  #     sudo -u $USERNAME brew uninstall php53-xhprof
  #     sudo -u $USERNAME brew uninstall php53
  #     sudo -u $USERNAME brew uninstall nginx
  #     sudo -u $USERNAME brew uninstall pcre geoip
  #     sudo -u $USERNAME brew uninstall dnsmasq
  #     sudo -u $USERNAME brew uninstall drush
  #     sudo -u $USERNAME brew uninstall gzip
  #     sudo -u $USERNAME brew uninstall wget
  #     printf "Removing related configurations..\n"
  #     rm -rf /usr/local/etc/nginx
  #     rm -rf /usr/local/etc/php
  #     rm -rf /usr/local/etc/dnsmasq.conf
  #   else
  #     printf "Exiting..\n"
  #     exit
  #   fi
  # else
  #   printf "Exiting..\n"
  #   exit
  # fi
fi

printf "You will need to watch this script as there are a few places where input is required..\n\n"
printf "What you would like your machines hostname to be?\n"
printf "It must end in .ld, eg: realityloop.ld: "
read HNAME
printf "\nYour hostname will be set to: $HNAME \n"

printf "What address should get aegirs email notifications?: "
read EMAIL
printf "\nAegir will send emails to: $EMAIL \n"


printf "Checking OS version..\n"
if [ $OSX = 10.8.4 -o $OSX = 10.8.5 ] ; then # -o $OSX = 10.9 , not working atm due to a bug in Mavericks
  printf "Your OS is new enough, so let's go!"
else
  printf "\nThis hasn't been tested with your version of Mac OS X, Do you want to continue? [y/n] "
  read CONTINUE
  if [ $CONTINUE != n -o $CONTINUE != N ] ; then
    printf "\nOK, attepting install..\n"
  else
    exit
  fi
fi


printf "\nChecking if the Command Line Tools are installed..\n"
if type "/usr/bin/clang" > /dev/null 2>&1; then
  printf "Woot! They're installed.\n"
else
  printf "Nope. You need the Command Line tools installed before this script will work\n\n"
  printf "You will need to install them via the Xcode Preferences/Downloads tab:\n"
  printf "   http://itunes.apple.com/au/app/xcode/id497799835?mt=12\n\n"
  printf "Run the script again after you've installed them.\n"
  exit
fi


printf "Checking if Homebrew is installed..\n"
if type "brew" > /dev/null 2>&1; then
  printf "Affirmative! Lets make sure everything is up to date..\n"
  printf "Just so you know, this may throw a few warnings..\n"
  sudo -u $USERNAME brew prune
  sudo -u $USERNAME brew update
  sudo -u $USERNAME brew doctor
else
  printf "Nope! Installing Homebrew now..\n"
  sudo -u $USERNAME ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
  sudo -u $USERNAME bash -c 'echo  "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.bash_profile'
  sudo -u $USERNAME bash -c 'echo  "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.zshrc'
  export PATH=/usr/local/bin:/usr/local/sbin:$PATH
  sudo -u $USERNAME brew doctor
fi


# Tap required kegs
printf "Now we'll tap some extra kegs we need..\n"
printf "I will throw errors if they're already tapped, nothing to worry about..\n"
sudo -u $USERNAME brew tap homebrew/dupes
sudo -u $USERNAME brew tap josegonzalez/homebrew-php


# Install required formula's
printf "Installing required brew formulas..\n"
printf "Installing wget..\n"
sudo -u $USERNAME brew install wget
printf "Installing gzip..\n"
sudo -u $USERNAME brew install gzip
printf "Installing drush..\n"
sudo -u $USERNAME brew install drush
printf "Installing dnsmasq..\n"
sudo -u $USERNAME brew install dnsmasq
printf "Configuring dnsmasq..\n"
sudo -u $USERNAME mkdir -p /usr/local/etc


# Configure dnsmasq
if [ -e "/usr/local/etc/dnsmasq.conf" ] ; then
  printf "You already have a dnsmasq.conf file..\nSo this all works proerly I'm going to delete and recreate it..\n"
  sudo -u $USERNAME rm /usr/local/etc/dnsmasq.conf
fi

printf "Setting dnsmasq config..\n"
sudo -u $USERNAME cp $(brew --prefix dnsmasq)/dnsmasq.conf.example /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME echo '# Edited by MEMPAE script' | cat - /usr/local/etc/dnsmasq.conf > temp && mv temp /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME echo "resolv-file=/etc/resolv.dnsmasq.conf" >> /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME echo "address=/.ld/127.0.0.1" >> /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME echo "listen-address=127.0.0.1" >> /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME echo "addn-hosts=/usr/local/etc/dnsmasq.hosts" >> /usr/local/etc/dnsmasq.conf
sudo -u $USERNAME touch /usr/local/etc/dnsmasq.hosts

if [ -e "/etc/resolv.dnsmasq.conf" ] ; then
  printf "You already have a resolv.conf set..\nSo this all works proerly I'm going to delete and recreate it..\n"
  rm /etc/resolv.dnsmasq.conf
fi

printf "Setting OpenDNS and Google DNS servers as fallbacks..\n"
echo "# OpenDNS IPv6:
nameserver 2620:0:ccd::2
nameserver 2620:0:ccc::2
# Google IPv6:
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
# OpenDNS:
nameserver 208.67.222.222
nameserver 208.67.220.220
# Google:
nameserver 8.8.8.8
nameserver 8.8.4.4" >> /etc/resolv.dnsmasq.conf

if [ -e "/etc/resolver/default" ] ; then
  printf "You already have a resolver set for when you are offline..\nSo this all works proerly I'm going to delete and recreate it..\n"
  rm /etc/resolver/default
fi

printf "Making local domains resolve when your disconnected from net..\n"
mkdir -p /etc/resolver
echo "nameserver 127.0.0.1
domain ." >> /etc/resolver/default

printf "Setting network interfaces to use 127.0.0.1 for DNS lookups, this will error on nonexistent interfaces..\n"
networksetup -setdnsservers AirPort 127.0.0.1
networksetup -setdnsservers Ethernet 127.0.0.1
networksetup -setdnsservers 'Thunderbolt Ethernet' 127.0.0.1
networksetup -setdnsservers Wi-Fi 127.0.0.1

printf "Setting hostname to $HNAME..\n"
scutil --set HostName $HNAME


# Start dnsmasq
printf "Starting dnsmasq..\n"
cp $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist


printf "Installing nginx..\n"
sudo -u $USERNAME brew install pcre geoip
sudo -u $USERNAME brew install https://gist.github.com/BrianGilbert/5908548/raw/4e36bff848c4552062861ff66e30b841605ad4e0/nginx.rb --with-realip --with-gzip --with-stub --with-webdav --with-flv --with-mp4 --with-geoip --with-upload --with-ssl
printf "Configuring nginx..\n"
if [ -e "/usr/local/etc/nginx/nginx.conf" ] ; then
sudo -u $USERNAME mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
fi
sudo -u $USERNAME curl https://gist.github.com/BrianGilbert/5908352/raw/26e5943ec52c1d43c867fc16c4960e291b17f7d2/nginx.conf > /usr/local/etc/nginx/nginx.conf
sudo -u $USERNAME sed -i '' 's/\[username\]/'$USERNAME'/' /usr/local/etc/nginx/nginx.conf
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx


printf "Installing mariadb..\n"
sudo -u $USERNAME bash -c 'brew install mariadb --env=std;unset TMPDIR'
printf "Configuring mariadb..\n"
sudo -u $USERNAME mysql_install_db --user=$USERNAME --basedir="$(brew --prefix mariadb)" --datadir=/usr/local/var/mysql --tmpdir=/tmp


printf "Installing php..\n"
sudo -u $USERNAME brew install php53 --with-mysql --with-fpm --with-imap
sudo -u $USERNAME brew install php53-xhprof
sudo -u $USERNAME brew install php53-xdebug
sudo -u $USERNAME brew install php53-uploadprogress


printf "Configuring php..\n"
sudo -u $USERNAME sed -i '' '/timezone =/ a\
date.timezone = Australia/Melbourne\
' /usr/local/etc/php/5.3/php.ini
sudo -u $USERNAME sed -i '' 's/post_max_size = .*/post_max_size = '50M'/' /usr/local/etc/php/5.3/php.ini
sudo -u $USERNAME sed -i '' 's/upload_max_filesize = .*/upload_max_filesize = '10M'/' /usr/local/etc/php/5.3/php.ini
sudo -u $USERNAME sed -i '' 's/max_execution_time = .*/max_execution_time = '90'/' /usr/local/etc/php/5.3/php.ini
sudo -u $USERNAME sed -i '' 's/memory_limit = .*/memory_limit = '512M'/' /usr/local/etc/php/5.3/php.ini
sudo -u $USERNAME sed -i '' '/pid = run/ a\
pid = /usr/local/var/run/php-fpm.pid\
' /usr/local/etc/php/5.3/php-fpm.conf

ln -s $(brew --prefix josegonzalez/php/php53)/var/log/php-fpm.log /var/log/nginx/php-fpm.log


printf "Setting up launch daemons..\n"
cp $(brew --prefix nginx)/homebrew.mxcl.nginx.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

sudo -u $USERNAME mkdir -p ~/Library/LaunchAgents
sudo -u $USERNAME cp $(brew --prefix mariadb)/homebrew.mxcl.mariadb.plist ~/Library/LaunchAgents/
sudo -u $USERNAME cp $(brew --prefix josegonzalez/php/php53)/homebrew-php.josegonzalez.php53.plist ~/Library/LaunchAgents/


printf "Launching daemons now..\n"
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
sudo -u $USERNAME launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
sudo -u $USERNAME launchctl load -w ~/Library/LaunchAgents/homebrew-php.josegonzalez.php53.plist


printf "Finishing mariadb setup..\n"
echo "Enter the following when prompted..

Current password: [hit enter]
Set root password?: [Y/n] y
New password: [make it easy, eg. mysql]
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y" #remove this echo when expects block below is fixed.

PATH="/usr/local/bin:/usr/local/sbin:$PATH" $(brew --prefix mariadb)/bin/mysql_secure_installation #remove this line when expects block below is fixed.
# This expect block throws error
# /usr/local/opt/mariadb/bin/mysql_secure_installation: line 379: find_mysql_client: command not found
# Any help greatly appreciated..
#
# expect -c "
#   spawn PATH="/usr/local/bin:/usr/local/sbin:$PATH" \\$(brew --prefix mariadb)/bin/mysql_secure_installation
#   expect \"Enter current password for root (enter for none):\"
#   send \"\r\"
#   expect \"Set root password?: \\\\\\[Y/n\\\\\\]\"
#   send \"y\r\"
#   expect \"New password:\"
#   send \"mysql\r\"
#   expect \"Re-enter new password:\"
#   send \"mysql\r\"
#   expect \"Remove anonymous users? \\\\\\[Y/n\\\\\\]\"
#   send \"y\r\"
#   expect \"Disallow root login remotely? \\\\\\[Y/n\\\\\\]\"
#   send \"y\r\"
#   expect \"Remove test database and access to it? \\\\\\[Y/n\\\\\\]\"
#   send \"y\r\"
#   expect \"Reload privilege tables now? \\\\\\[Y/n\\\\\\]\"
#   send \"y\r\"
#   expect eof"


printf "Doing some setup ready for Aegir install..\n"
mkdir -p /var/aegir
chown $USERNAME /var/aegir
chgrp staff /var/aegir
dscl . append /Groups/_www GroupMembership $USERNAME
echo "$USERNAME ALL=NOPASSWD: /usr/local/bin/nginx" >> /etc/sudoers
ln -s /var/aegir/config/nginx.conf /usr/local/etc/nginx/aegir.conf


printf "Adding aegir.conf include to ngix.conf..\n"
sudo -u $USERNAME ed -s /usr/local/etc/nginx/nginx.conf <<< $'g/#aegir/s!!include /usr/local/etc/nginx/aegir.conf;!\nw'


printf "Aegir time..\n"
printf "Downloading provision..\n"
sudo -u $USERNAME drush dl --destination=/users/$USERNAME/.drush provision-6.x-2.x
printf "Clearing drush caches..\n"
sudo -u $USERNAME drush cache-clear drush
printf "Installing hostmaster..\n"

sudo -u $USERNAME PATH="/usr/local/bin:/usr/local/sbin:$PATH" drush hostmaster-install --aegir_root='/var/aegir' --root='/var/aegir/hostmaster-6.x-2.x-dev' --http_service_type=nginx --aegir_host=aegir.ld  --client_email=$EMAIL aegir.ld #remove this line when/if expects block below is enabled again.
# This expect block works but the previous expect block doesn't so can't use this yet.
#
# expect -c "
#   spawn sudo -u $USERNAME PATH=\"/usr/local/bin:/usr/local/sbin:$PATH\" drush hostmaster-install --aegir_root='/var/aegir' --root='/var/aegir/hostmaster-6.x-2.x-dev' --http_service_type=nginx --aegir_host=aegir.ld  --client_email=$EMAIL aegir.ld
#   expect \") password:\"
#   send \"mysql\r\"
#   expect \"Do you really want to proceed with the install (y/n):\"
#   send \"y\r\"
#   expect eof"


printf "Symlinking platforms to ~/Sites/aegir..\n"
sudo -u $USERNAME mkdir -p /Users/$USERNAME/Sites/aegir
sudo -u $USERNAME rmdir /var/aegir/platforms
sudo -u $USERNAME ln -s /Users/$USERNAME/Sites/aegir /var/aegir/platforms


printf "The date.timezone value is set to Melbourne/Australia in /usr/local/etc/php/[version]/php.ini, you may want to change it to something that suits you better.\n"
printf "The mysql root password is set to 'mysql' and login is only possible from localhost..\n"
printf "Double check your network interfaces to ensure their DNS server is set to 127.0.0.1 as we only tried to set commonly named interfaces.\n"
printf "Fin..\n"
exit