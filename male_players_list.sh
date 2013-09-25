#!/bin/bash

#######################################################################
#  Running the script we have a connection with a database           #
#  and we retreive the email and  full_name of only the male users   #
######################################################################


#create timestamp to append it to the filename
timestamp=$( date +%d%m%y%H%M%S )

#create temporal txt file for the sql-results
touch ns_male_list.txt

echo 'connect to the database'

#use the host_name, username, password and database_name
mysql --host=host_name --user=username --password=password -e "use database_name; select DISTINCT(CONCAT_WS('\",\"',ui.email, ui.fullName)) as \" email, full_name\" from user_table as ut inner join userinfo as ui on ut.key1=ui.key1 where ui.email <> '' and ui.gender = 'male' " > ns_male_list.txt

echo 'creating the csv file'
sed 's/^[ ]*/"/g' ns_male_list.txt | sed 's/$/"/g' > final_male_list_"$timestamp".csv
