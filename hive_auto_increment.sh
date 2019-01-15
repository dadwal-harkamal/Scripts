#/bin/bash
#### This script basically implements the auto increment functinality for HIVE tables ###
### Create atemporrary table in the DB with the max value from the table for which you want to implement the autoincrement feature ###
### This can be achieved by using simple insert using selelct stmt###
#### aftre that use the below hive stmts, use this alongwith the actual insert g=hive stmts. #########

var=$(hive -e "use test; select * from  t_auto_incr")
echo $var
hive -e "use test; select row_sequence()+$var"
