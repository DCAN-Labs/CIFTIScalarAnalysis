#! /bin/bash
#CreatePALMCIFTIMaps.sh is used to generate CIFTI maps from PALM statistical outputs. 
#Simply provide the paramfile used in PrepCIFTIsForPALM.sh and the files will be generated.
#If PALM outputs were not generated using PrepCIFTIsForPALM.sh, make sure to rename the cortical and volumetric outputs accordingly (see below)
#If "clean_up_data" is set to true in the parameter file. The merged data folder will be deleted, to save space though the subject scalar file will be maintained to reproduce the maps.
#NOTE: after generating the CIFTI maps, and double-checking to make sure they are correct, one can archive the ouput from the CIFTI analysis.
#
#
#
#
#Usage: CreatePALMCIFTIMaps.sh parameter_file.params
source $1
pushd ${output_directory}/PALManalysis/
mkdir ../CIFTI_outputs
for image in `ls VOLUME_*.nii`; do 
	statfile=`expr "$image" | sed s/VOLUME_// | sed s/.nii//`
 	if [ `expr "$statfile" : \vox` == 0 ]; then
#edit the prefixes (or rename the files) in the command below for VOLUME,LEFT_CORTEX,and RIGHT_CORTEX, if generated differently. Or just rename your outputs :)
		wb_command -cifti-create-dense-from-template ../merged_data/all_data.dscalar.nii ../CIFTI_outputs/results_${statfile}.dscalar.nii -volume-all VOLUME_${statfile}.nii -metric CORTEX_LEFT LEFT_CORTEX_${statfile}.gii -metric CORTEX_RIGHT RIGHT_CORTEX_${statfile}.gii 
	fi
done
if $clean_up_data; then rm -rf ${output_directory}/merged_data; rm -rf ${output_directory}/PALManalysis; fi
