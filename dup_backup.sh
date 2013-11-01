#!/bin/bash

###########################################################
# You might need to export your aws access and secret keys#
##########################################################


echo "give the private ip of the instance:"
read pr_ip

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

var=true
while [ $var == "true" ]
do

echo -e "\033[01;34m Choose one of the following options:\033[00;00m"
echo -e "\033[01;34m 1) check for duplicity tool\033[00;00m"
echo -e "\033[01;34m 2) take a full backup\033[00;00m"
echo -e "\033[01;34m 3) force remove all backups except the last n-th full backup \033[00;00m"
echo -e "\033[01;34m 4) download backup \033[00;00m"
echo -e "\033[01;34m 5) exit \033[00;00m"
read choice

case $choice in
"1") echo -e "\033[01;33m ======== check for duplicity tool ======= \033[00;00m"
        
        cd /usr/bin
        
        if [ -f duplicity ]
        then
            echo "duplicity is already installed"
        else
            echo "duplicity not found. Do you want to install it?(Y/N)"
            read dup
            
            case $dup in
            "Y|y") sudo apt-get install duplicity
                   ;;
            "N|n") ReturnToMenu
                   ;;
            esac
        fi
     ReturnToMenu
     ;;
     
"2") echo -e "\033[01;33m ======== take a full backup ======= \033[00;00m"
        timestamp=$( date +%d%m%y%H%M )
        mkdir -p ~/backups/backup_"$timestamp"
        B_PATH="~/backups/backup_$timestamp"

        echo "give the username:"
	read uname

	echo "give the password"
	read pw

        cd /opt/couchbase/bin
        echo "take couchbase backup"
        ./cbbackup http://$pr_ip:8091 ~/backups/backup_$timestamp -u $uname -p $pw

	cd /home/ubuntu/Downloads/ec2-api-tools-1.6.11.0/bin/

        #print the instance id from the specific public-dns
        ins_id=$(ec2-describe-instances | grep $pr_ip | cut -f 2)

        #print the name of the instance
        sub_folder=$(ec2-describe-tags --filter "key=Name" | grep $ins_id | cut -f 5)

        echo "store the backup to s3"
        duplicity full --no-encryption $B_PATH s3://s3-eu-west-1.amazonaws.com/crowdpark-backup-test/$sub_folder

	cd ~/backups/
	rm -rf backup_"$timestamp"
     ReturnToMenu
     ;;
        
"3") echo -e "\033[01;33m ======== force remove all backups except the last n-th full backup ======= \033[00;00m"

        #print the instance id from the specific public-dns
        ins_id=$(ec2-describe-instances | grep $pr_ip | cut -f 2)

        #print the name of the instance
        sub_folder=$(ec2-describe-tags --filter "key=Name" | grep $ins_id | cut -f 5)
        
        echo "give the number of the backups you want to delete:"
        read n
        
        #force remove all backups except the last full backup
        duplicity remove-all-but-n-full $n --force s3://s3-eu-west-1.amazonaws.com/crowdpark-backup-test/$sub_folder
        
     ReturnToMenu
     ;;
     
"4") echo -e "\033[01;33m ======== download backup ======= \033[00;00m"

	echo "give the time format: "
	echo "<number> + H for hours"
	echo "<number> + D for days"
	echo "<number> + W for weeks"
	echo "<number> + M for months"
	echo "exp: 4D -> before 4 days"
	read nd

        #print the instance id from the specific public-dns
        ins_id=$(ec2-describe-instances | grep $pr_ip | cut -f 2)

        #print the name of the instance
        sub_folder=$(ec2-describe-tags --filter "key=Name" | grep $ins_id | cut -f 5)

	echo "retrieve the backup from the s3"
        #force remove all backups except the last full backup
        duplicity restore --no-encryption -t $nd s3://s3-eu-west-1.amazonaws.com/crowdpark-backup-test/$sub_folder ~/restores/$sub_folder

     ReturnToMenu
     ;;
     
"5") echo -e "bye!"
      var=false
    ;;
    
*) echo -e "\033[01;35m Choose a NUMBER between 1-5 ! \033[00;00m"
   ;;
esac

done
