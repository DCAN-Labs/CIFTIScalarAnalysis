#!/bin/sh
conc_path=$1
job_path=$2
mkdir ${job_path}
conc_files=`ls ${conc_path}/*.params`
iterjob=1
for conc in ${conc_files}
	do ssub -t 120:: -J ${job_path}/conc_${iterjob} PrepCIFTIsForPALM.sh ${conc}
	iterjob=`expr ${iterjob} + 1`
	sleep 5
done
