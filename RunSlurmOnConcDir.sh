#!/bin/sh
conc_path=$1
conc_files=`ls ${conc_path}/*.params`
iterjob=1
for conc in ${conc_files}
	do ssub -t 120:: -J conc_${iterjob} PrepCIFTIsForPALM.sh ${conc}
	iterjob=`expr ${iterjob} + 1`
	sleep 5
done
