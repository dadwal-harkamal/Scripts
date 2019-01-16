#/bin/bash
#### This script basically implements the auto increment functinality for HIVE tables ###
## before using this script just add the row_sequence() function ( ex. this in HIVE CLI or any HIVE client) in the DB where you want to implement auto increment##
## CREATE  FUNCTION row_sequence as 'org.apache.hadoop.hive.contrib.udf.UDFRowSequence';
### Create atemporrary table in the DB with the max value from the table for which you want to implement the autoincrement feature ###
### This can be achieved by using simple insert using select stmt###
#### aftre that use the below hive stmts, use this alongwith the actual insert hive stmts. #########

var=$(hive -e "use test; select * from  t_auto_incr")
echo $var
hive -e "use test; select row_sequence()+$var"
