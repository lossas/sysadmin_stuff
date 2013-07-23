#!/bin/bash

#function to print the output of a command to the terminal and to a file(logfile_xxxxx.txt)
function log_function(){
    timestamp=$( date +%d%m%y%H%M)
    
    if [ $1 == 'cd' ]
    then
      if [ -d $2 ]
       then
          cd $2
          echo $2 >> ./logfile_"$timestamp".txt
   
       else
       	echo "$2 does not exist!!!"
        echo "$2 does not exist!!!" >> ./logfile_"$timestamp".txt
       fi
    else
     #please change the path, where you want the logfile to be saved
    $@ 2>&1 | tee -a logfile_"$timestamp".txt
    fi

}

#example how to use the command
#log_function tar -cvf yacg.tar ../www/yacg
log_function cd /Users/leonidasdasdadas