#!/bin/bash

###############################################
# A script that checks the dev-server   #######
# the execution of the script is:      ########
# ./check_server <username> <ip>      #########
###############################################

ssh -t $1\@$2 '

function ReturnToMenu {
    echo -e "\033[01;35m Do you want to return to the main menu or to quit the script? (M|q)\033[00;00m"
    
    read continue
    case $continue in
    [mM]) var=true
     ;;
    "q") var=false
         echo -e "\033[01;35m good bye!\033[00;00m"
         exit 1
     ;;
     *) var=true
         ReturnToMenu
     ;;    
     esac
}

function InstallAWS_Tools {
    sudo apt-get update
    sudo apt-get install -y openjdk-6-jre ruby1.8-full rubygems libxml2-utils libxml2-dev libxslt-dev unzip cpanminus build-essential
    sudo gem install uuidtools json httparty nokogiri
    
    if [ ! -d $HOME/aws-tools/ ]
    then
        mkdir -p $HOME/aws-tools/
        cd $HOME/Couchbase/aws-tools
    else
        cd $HOME/Couchbase/aws-tools
    fi    
        
    echo "install EC2 API command line tools"
    wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
    unzip ec2-api-tools.zip
    sudo rsync -a --no-o --no-g ec2-api-tools-*/ /usr/local/aws/ec2/
      
    echo "install EC2 AMI command line tools"
    wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
    unzip ec2-ami-tools.zip
    sudo rsync -a --no-o --no-g ec2-ami-tools-*/ /usr/local/aws/ec2/
       
    echo "install IAM command line tools"
    wget http://awsiammedia.s3.amazonaws.com/public/tools/cli/latest/IAMCli.zip
    unzip IAMCli.zip
    sudo rsync -a --no-o --no-g IAMCli-*/ /usr/local/aws/iam/
      
    echo "install RDS command line tools"
    wget http://s3.amazonaws.com/rds-downloads/RDSCli.zip
    unzip RDSCli.zip
    sudo rsync -a --no-o --no-g RDSCli-*/ /usr/local/aws/rds/
        
    echo "install ELB command line tools"
    wget http://ec2-downloads.s3.amazonaws.com/ElasticLoadBalancing.zip
    unzip ElasticLoadBalancing.zip
    sudo rsync -a --no-o --no-g ElasticLoadBalancing-*/ /usr/local/aws/elb/
}







function CheckDevServer {
for pkg in php5 php5-common php5-cli php5-curl php5-dev php5-fpm php5-memcached php5-memcache php5-mysql php5-suhosin php-apc php-pear
do
    p=$(ls /usr/share/doc | grep -c $pkg)
    if [ $p -gt 0 ]
    then
        echo "$pkg is already installed"
    else
        echo "$pkg will be installed automatically..."
        sleep 3
        sudo apt-get install $pkg
    fi
done
echo ""

#check for nginx
ng=$(ls /etc/init.d | grep -c nginx)

if [ $ng == 1 ]
then
    echo "nginx is already installed"
else
    echo "nginx will be installed automatically..."
    sleep 3
    sudo apt-get install nginx
fi

for software in nginx php
do
$software -v
done
echo ""

#check for node.js
nd=$(ls /usr/bin | grep -c nodejs)

if [ $ng == 1 ]
then
    echo "node.js is already installed"
else
    echo "nodejs will be installed automatically..."
    sleep 3
    sudo apt-get install python-software-properties python g++ make
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install nodejs
fi
echo ""

#check for couchbase-server
cb=$(ls /opt/couchbase/bin/ | grep -c couchbase-server)

if [ $cb == 1 ]
then
   echo "couchbase-server is installed"
else
   echo "couchbase-server will be installed automatically..."
   sleep 3
   
    if [ ! -d $HOME/Couchbase/ ]
    then
        mkdir -p $HOME/Couchbase/ 
        cd $HOME/Couchbase/
    else
        cd $HOME/Couchbase/
    fi
   
   wget http://packages.couchbase.com/releases/2.0.1/couchbase-server-enterprise_x86_64_2.0.1.deb
   dpkg -i couchbase-server-enterprise_x86_64_2.0.1.deb
fi

#check for php-ext-couchbase
cb_ext=$(php -m | grep -c couchbase)

if [ $cb_ext == 1 ]
then
    echo "couchbase extension for php is installed."
else
    echo "couchbase extension for php is missing and will be installed automatically..."
    sleep 3
    sudo aptitude install libssl0.9.8 php5-dev php-pear unzip
    echo "add couchbase to the repositories"
    sudo wget -O/etc/apt/sources.list.d/couchbase.list http://packages.couchbase.com/ubuntu/couchbase-ubuntu1204.list
    sudo aptitude update
    echo "install the couchbase-libs"
    sudo aptitude install libcouchbase-dev libcouchbase-dbg libcouchbase2 libcouchbase2-backend libcouchbase2-core libcouchbase2-libevent
    
    if [ ! -d $HOME/Couchbase/ ]
    then
        mkdir -p $HOME/Couchbase/ 
        cd $HOME/Couchbase/
    else
        cd $HOME/Couchbase/
    fi
    
    echo "download and unzip the libcouchbase package"
    wget https://github.com/couchbaselabs/php-ext-couchbase/zipball/master
    unzip couchbaselabs-php-ext-couchbase-*.zip
    cd couchbaselabs-php-ext-couchbase-*
    
    phpize
    echo "compile and install the libcouchbase package"
    ./configure
    make
    sudo make install
    echo "create new couchbase.ini file"
    sudo touch /etc/php5/conf.d/couchbase.ini
    sudo echo "extension=couchbase.so" > /etc/php5/conf.d/couchbase.ini
fi
echo ""

#check for the git
      git=$(ls /usr/bin/ | grep ^git$)
        if [ $git == "git" ]
        then
           git --version
        else
           echo "git is going to be installed automatically"
           sleep 5
           sudo apt-get install git
        fi
}

var=true
while [ $var == "true" ]
do

echo -e "\033[01;34m Choose one of the following options:\033[00;00m"
echo -e "\033[01;34m 1) check for ssh-key\033[00;00m"
echo -e "\033[01;34m 2) check for free disk space\033[00;00m"
echo -e "\033[01;34m 3) report information about process, memory, cpu activity etc.\033[00;00m"
echo -e "\033[01;34m 4) print I/O network statistics \033[00;00m"
echo -e "\033[01;34m 5) output information about operating system\033[00;00m"
echo -e "\033[01;34m 6) use the aptitude tool to examine your packages/libs\033[00;00m"
echo -e "\033[01;34m 7) list services that listen to tcp and udp port\033[00;00m"
echo -e "\033[01;34m 8) search for a packet\033[00;00m"
echo -e "\033[01;34m 9) check for amazon-tools\033[00;00m"
echo -e "\033[01;34m 10) check the server for dev-tools\033[00;00m"
echo -e "\033[01;34m 11) exit \033[00;00m"
read choice

case $choice in
"1") echo -e "\033[01;33m ======== check for ssh-key ======= \033[00;00m"
      
      key=$(ls $HOME/.ssh | grep -c pub$)
      if [ $key -eq "0" ]
      then
         echo "User $USER has no ssh-keys in this server."
         echo "The keys are going to be created..."
         ssh-keygen -t rsa -b 4096
       else
         echo "User $USER has this public key: "
         #ls $HOME/.ssh | grep pub$
         find $HOME/.ssh -name *.pub 
         echo "Do you want to read your public key? (Y|n)"
         read key
            case $key in
            [Yy]) cd $HOME/.ssh/
                  cat *.pub
                  ;;
            [Nn]) ReturnToMenu
                  ;;
            esac
       fi
         
     ReturnToMenu
     ;;
"2") echo -e "\033[01;33m ======== check for disk space ======= \033[00;00m"
     df -h
     
     ReturnToMenu
     ;;
"3") echo -e "\033[01;33m ======== reports information about processes, memory, paging, block IO, traps, and cpu activity (MBs) ========== \033[00;00m"
     vmstat -SM
     echo -e "\033[01;33m ======== prints memory usage ========== \033[00;00m"
     free -m
     
     ReturnToMenu
     ;;
"4") echo -e "\033[01;33m ======== print I/O network statistics ======== \033[00;00m"
     stats=$(ls /etc/init.d/ | grep sysstat)
        if [ $stats == "sysstat" ]
        then
           iostat -N -m
        else
           sudo apt-get install sysstat
           iostat -N -m
        fi

       ReturnToMenu 
     ;;
"5") echo -e "\033[01;33m ======== output information about the operating system that you are using ========== \033[00;00m"
     uname -a
     
     ReturnToMenu
     ;;
"6") echo -e "\033[01;33m ============= using aptitude -- be careful with what are you doing! ============= \033[00;00m"
     sudo aptitude
     
        ReturnToMenu
     ;;
"7") echo -e "\033[01;33m ============= list services which listens to tcp and udp port ================ \033[00;00m"
     sudo netstat -npl

        ReturnToMenu 
     ;;
"8") echo -e "\033[01;33m ============= search for a file ================ \033[00;00m"
       echo "give the name of the packet you want to search for: "
       read packet

       p=$(dpkg --get-selections)
       echo "$p" | grep -q "$packet"
        if [ $? -eq 0 ];then
            echo "packet is already installed"
        else
            echo "Packet not fount. Do you want to install it now? (Y|n)"
            read ins
                if [ $ins == "Y" ]
                then
                    sudo apt-get install $packet
                    echo "Packet is installed."
                fi
        fi
        
        ReturnToMenu
    ;;
"9") echo -e "\033[01;33m ============= search for amazon-tools ================ \033[00;00m"

      if [ -d /usr/local/aws ];then
        cd /usr/local/aws
        for pkg in ec2 elb iam rds
        do
            tool=$(ls | grep $pkg$ )
            if [ $tool == $pkg ]
            then
                echo "$tool :"
                tree -L 1 ./$tool
            else
                echo "$tool is missing"
            fi
        done

      else
        sudo mkdir -p /usr/local/aws
        cd /usr/local/aws
        #install aws-tools ....
        InstallAWS_Tools
      
      fi
    
    ReturnToMenu
    ;;
"10") echo -e "\033[01;33m ============= search to the server for dev-tools ================ \033[00;00m"   
      CheckDevServer
      ReturnToMenu
    ;;
"11") echo -e "bye!"
      var=false
    ;;

*) echo -e "\033[01;35m Choose a NUMBER between 1-11 ! \033[00;00m"
   ;;
esac

done
'
