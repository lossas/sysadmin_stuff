 function log_function_v2(){
 
    local logFile=./logfile_$( date +%d%m%y%H%M).txt
    if [ $1 == 'cd' ]
        then
            echo "cd $2 ..." 2>&1 | tee -a $logFile
            cd $2
            echo " --> you are here: $(pwd)" 2>&1 | tee -a $logFile
            return
    fi
 
    $@ 2>&1 | tee -a $logFile
}