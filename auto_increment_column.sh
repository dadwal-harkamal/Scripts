#/bin/bash
### This script basically implements the auto increment functi0nality for HIVE tables                                                                          ###
### Create a temporary table in the DB with the max value from the table for which you want to implement the auto-increment feature                            ###
### row_sequnce() is not working with insert stmt. so I had to fetch the data using select stmt and copied it over to another table along with row_sequence()  ###
### and finally moved to the main table from this table                                                                                                        ###
### I need to test this full functionality along with the real select stmt for new financial summary report Stored procedure                                   ###

var=$(hive -e "use test; select max(newfinancialsummaryid) from  TEMP_INS_NUM_ACCOUNTS")
#echo $var

#hive -e "use test; select row_sequence()+$var"

hive -e "use test; select iaid,transitid,fieldsummaryid,registeredamount,nonregisteredamount,validfromdate,validtodate,monthdate,row_sequence()+$var from TEMP_INS_NUM_ACCOUNTS_CSV" > /home/c42787@atb.ab.com/auto_increment.tsv

hadoop fs -put /home/c42787@atb.ab.com/auto_increment.tsv /apps/hive/warehouse/

hive -e "use test; drop table if exists incr_temp_ins_num_accounts"

hive -e "use test; CREATE TABLE incr_temp_ins_num_accounts (iaid int, transitid varchar(3), fieldsummaryid int, registeredamount decimal(18,2), nonregisteredamount decimal(18,2), validfromdate timestamp, validtodate timestamp, monthdate timestamp, newfinancialsummaryid bigint )  CLUSTERED BY (iaid) INTO 2 BUCKETS ROW FORMAT DELIMITED  FIELDS TERMINATED BY '\t'  STORED AS TEXTFILE"


hive -e "use test; load data inpath '/apps/hive/warehouse/auto_increment.tsv' into table INCR_TEMP_INS_NUM_ACCOUNTS"

hive -e "use test; INSERT into TABLE TEMP_INS_NUM_ACCOUNTS  select * from INCR_TEMP_INS_NUM_ACCOUNTS"
