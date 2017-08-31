#!/bin/sh
conc_path=$1
job_path=$2
partition=$3
partition=${partition:-'exacloud'}
mkdir ${job_path}
conc_files=`ls ${conc_path}/*.params`
iterjob=1
for conc in ${conc_files}
	do srun --quiet -o ${job_path}/conc_${iterjob}.out -e ${job_path}/conc_${iterjob}.err --partition ${partition} --time 1-12:0 PrepCIFTIsForPALM.sh ${conc} & disown
	iterjob=`expr ${iterjob} + 1`
	sleep 5
done
