#!/bin/bash
# error handling: terminate script on error
set -e

#######################################################
#                                                     #
# script for the automate-setup of a dev-environement #
# on a MAC-OS                                         #
# it creates - the working directory ( ~/www )        #
#            - the ssh-keys (pub and private)         #
#            - the git initial directory              #
# it installs - the crwd-tools                        #
#             - brew                                  #
#             - nginx, php5.3, php-modules            #
#                                                     #
#######################################################

CROWD_TOOLS_PATH="$HOME/www/crwd-tools"


echo ''
echo '--- create www directory if it is missing'

if [ -d $HOME/www ]
then
   echo 'www directory already exists'
else
   mkdir $HOME/www
   echo 'directory was created'
fi

echo ''
echo '--- search for ssh-key'
if [ -f $HOME/.ssh/*.pub ]
then
    echo "User $USER has already ssh-keys"
else
ssh-keygen -t rsa -C ' $USER ssh-key'
fi

echo ''
echo '--- create git initial directory under www'

cd $HOME/www
git init

echo '--- install Crowdpark crwd-tools from github '
if [ -d $CROWD_TOOLS_PATH ]
then
    echo "crwd-tools are already installed... go to $CROWD_TOOLS_PATH and run - git pull origin master - for update."
else 
     cd $HOME/www
     echo '--- clone crowdpark tools form github'
     git clone --recursive https://github.com/Crowdpark/crwd-tools crwd-tools
     cd crwd-tools
fi
cd $CROWD_TOOLS_PATH
./local-setup.sh
# local-setup calls nginx-setup to install nginx-php53 and some modules from php...
echo ''
echo "done."

echo '--- start nginx and php-fpm'
cd $CROWD_TOOLS_PATH/scripts
./nginx.sh start
./php-fpm.sh start

cb_server=$(find /Applications -name couchbase-server | grep -c couchbase-server)
if [ $cb_server -gt 0 ]
then
    echo "couchbase-server is installed."
else
    brew install wget
    if [ ! -d $HOME/Couchbase ]
    then
        mkdir -p $HOME/Couchbase
        cd $HOME/Couchbase
        wget http://packages.couchbase.com/releases/2.0.1/couchbase-server-community_x86_64_2.0.1.zip
        unzip couchbase-server-community_x86_64_2.0.1.zip -d ./couchbase-server
        cd couchbase-server
        cp -R "Couchbase Server.app" /Applications/
        open Couchbase\ Server.app/
        echo "Opening  the web-interface of couchbase-server (http://localhost:8091)...."
        sleep 6
        open http://localhost:8091
    else
        echo 'open couchbase server'
        open Couchbase\ Server.app/
    fi
fi

echo '--- install libcouchbase'
brew install https://github.com/couchbase/homebrew/raw/stable/Library/Formula/libcouchbase.rb

cd $HOME
echo ''
echo '--- install node.js'

njs=$(ls /usr/local/bin | grep -c node)
if [ $njs -gt 0 ]
then
    echo 'node.js is already installed'
else
    brew install node
fi
