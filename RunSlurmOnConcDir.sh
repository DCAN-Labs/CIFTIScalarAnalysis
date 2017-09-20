#!/bin/sh
conc_path=$1
job_path=$2
partition=$3
partition=${partition:-'exacloud'}
mkdir ${job_path}
conc_files=`ls ${conc_path}/*.params`
iterjob=1
for conc in ${conc_files}
	do source ${conc}
	if [ -d ${output_directory}/CIFTI_outputs ]; then
		echo "run for " ${output_directory} " exists and will be skipped"
		else
			touch ${job_path}/job_${iterjob}.sh
			echo '#!/usr/bin/bash' >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --cpus-per-task 1" >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --mem-per-cpu 2G" >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --partition ${partition}" >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --time 1-12:0" >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --error ${job_path}/conc_${iterjob}.err" >> ${job_path}/job_${iterjob}.sh
			echo "#SBATCH --output ${job_path}/conc_${iterjob}.out" >> ${job_path}/job_${iterjob}.sh
			echo "srun PrepCIFTIsForPALM.sh ${conc}" >> ${job_path}/job_${iterjob}.sh
			sbatch ${job_path}/job_${iterjob}.sh
		fi
	iterjob=`expr ${iterjob} + 1`
	sleep 10
done
