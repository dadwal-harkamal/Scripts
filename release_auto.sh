#!/bin/bash

repo_name=$1
tag=$2
tot_args=$#
email_to="hdadwal@atb.com"
replytoemails="atbbigdatasupport@atb.com"
log_file=bitbucket_release.log
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
bit_bucket_user_id=atbbigdatasupport

echo "${TIMESTAMP}: Script Started " >> ${log_file}

kinit -kt /etc/security/keytabs/hive.service.keytab hive/lxdb-cd-hwxm02.np.gcp.atbcloud.com@ATB.AB.COM
#getActiveNode="jdbc:hive2://lxdb-cd-hwxm01.np.gcp.atbcloud.com:2181,lxdb-cd-hwxm02.np.gcp.atbcloud.com:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2;ssl=true;sslTrustStore=/usr/hdp/current/hive-server2/conf/test2_hive_odbc_ssl.jks;trustStorePassword=Bigd@ta1;transportMode=http;httpPath=cliservice;"

getActiveNode="jdbc:hive2://lxdb-cd-hwxm02.np.gcp.atbcloud.com:10001/default;ssl=true;sslTrustStore=/usr/hdp/current/hive-server2/conf/test2_hive_odbc_ssl.jks;trustStorePassword=Bigd@ta1;transportMode=http;httpPath=cliservice;principal=hive/lxdb-cd-hwxm02.np.gcp.atbcloud.com@ATB.AB.COM;"

#echo $1
if [ ${tot_args} -lt 2 ] ; then

   echo   "${TIMESTAMP}: Missing Args!! please supply the correct number of args." | tee -a ${log_file}
   echo   "${TIMESTAMP}: Script usage is ./bitbucket_release.sh  repo_name  release_tag." | tee -a ${log_file}
   exit

fi


if [ ! -d ${repo_Name} ]; then

 git clone https://${bit_bucket_user_id}@bitbucket.org/atbdatapillar/${repo_Name}.git
  ## if clone command fails nothing gets executed after that script exits at this point"

fi

   cd $(pwd)/$1 >/dev/null 2>&1
   git fetch
   git show ${tag} > release_Info.txt
   show_status=$?
   if [ ${show_status} -ne 0 ];then
     echo "${TIMESTAMP}: git Show command (git show ${tag}) failed with an error code ${show_status} possible reason might be due to wrong Tag name pl. check" | tee -a ../${log_file}
     echo "----------------------------------------------------------------------------------------------------------------------------------------" >> ../${log_file}
     exit 1
   fi
   email_to=$(cat release_Info.txt | grep "Author" | cut -d"<" -f2 | cut -d">" -f1)
   #echo "${email_to}"
while read line
do

   file_part1=$(echo $line | cut -d" " -f1)

   if [ "${file_part1}" = "+++" ]; then

      file_part2=$(sed 's/+++/[/g' <<< $line | cut -d"[" -f2)
      file_name=$(sed 's/b\///g' <<< $file_part2)
      echo ${file_name}
      git pull https://${bit_bucket_user_id}@bitbucket.org/atbdatapillar/$repo_name.git/master/$file_name
      pull_comm_status=$?

      if [ ${pull_comm_status} -eq 0 ] ; then

        beeline -u $getActiveNode --silent=true -f $file_name > hive_query_res_temp
        beeline_status=$?

        if [ ${beeline_status} -eq 0 ]; then
                echo "${TIMESTAMP}: $file_name successfully executed in hive pl check your atb email" >> ../${log_file}
                echo "$file_name successfully executed in hive" | mailx -A atb_secure_smtp -s "Success" -a hive_query_res_temp -r $replytoemails $email_to

        else
                echo "$file_name failed to execute in hive, couldn't launch the beeline shell." >> ../${log_file}
                echo "$file_name failed to execute in hive  couldn't launch the beeline shell." | mailx -A atb_secure_smtp -s "Failure" -a hive_query_res_temp -r $replytoemails $email_to
        fi
        ## uncomment below section if you need to archive the files, at present no need as I am not creating any relasefile which is taking input from the user
        ##file=$(echo $file_name | cut-d"/" -f2)
        ##mkdir -p /releasearchive/$repo_name/
        ##cp $file_name /releasearchive/$repo_name/$file.$(date "+%Y-%m-%d_%H:%M:%S")
        ##echo "$file_name has been successfully archived at ./releasearchive/$repo_name" >> ../${log_file}


      fi

   else
       continue
   fi

done < $(pwd)/release_Info.txt

rm -rf release_Info.txt
rm -rf hive_query_res_temp
echo "${TIMESTAMP}: Script Ended " >> ../${log_file}
echo "----------------------------------------------------------------------------------------------------------------------------------------" >> ../${log_file}

