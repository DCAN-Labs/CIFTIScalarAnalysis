#! /bin/bash
#PrepCIFTIsForPALM.sh is used to prepare CIFTI and surface GIFTI files for analysis using FSL's Permutation Analysis of Linear Models
#A parameter file is required to use PrepCIFTIsForPALM. One should have the following files before running this script:
#
#parameter_file.params -- parameter file containing the options for running PALM, and directs I/O (Inputs/Outputs)
#concfile.conc -- a single column text file with the paths for each subject's HCP data (up to where the MNINonLinear folder is located)
#scalarfile.conc -- a single column text file  with the paths for each subject's dscalar data (should match the number and order of the concfile.conc, or errors will occur when running PALM)
#design_matrix.txt -- the design matrix as a tab-delimited text file, either handmade or output from PalmReader.m
#contrast_matrix.txt -- the contrast (weight) matrix  as a tab-delimited text file, either handmade or output from PalmReader.m
#
#The files below are optional for ANOVA and/or repeated measures analyses:
#
#ftest_matrix.txt -- the ftest matrix for anovas and repeated measures as a tab-delimited text file, either handmade or output from PalmReader.m
#rm_matrix.txt -- the "groups" matrix for repeated measures, determines which cases are exchangable for constructing appropriate permutations. Also can be handmade or output from PalmReader.m
#
#In addition, make sure all subjects have the appropriate MNINonLinear/fsaverage_LR32k/*L.midthickness*surf.gii and corresponding RH surface. In a pinch, the midthickness can be replaced with other surfaces.
#
#
#Usage: PrepCIFTIsForPALM.sh parameter_file.params
source $1
export PATH=$PATH:/usr/share/fsl/5.0/bin/ #sets the path to use Text2Vest change or comment out depending on the version
if [ -f ${design_file_paths}/design_matrix.txt ]; then
	if [ -f ${design_file_paths}/design.mat ]; then
		echo 'design matrix found'
	else
		Text2Vest ${design_file_paths}/design_matrix.txt ${design_file_paths}/design.mat
	fi
fi
if [ -f ${design_file_paths}/contrast_matrix.txt ]; then 
	if [ -f ${design_file_paths}/design.con ]; then
		echo 'contrast matrix found'
	else
		Text2Vest ${design_file_paths}/contrast_matrix.txt ${design_file_paths}/design.con
	fi
fi
if [ -f ${design_file_paths}/ftest_matrix.txt ]; then 
	if [ -f ${design_file_paths}/design.fts ]; then
		echo 'ftest matrix found'
	else
		Text2Vest ${design_file_paths}/ftest_matrix.txt ${design_file_paths}/design.fts
	fi
fi
if [ -f ${design_file_paths}/rm_matrix.txt ]; then 
	if [ -f ${design_file_paths}/design.grp ]; then
		echo 'group matrix found'
	else
		Text2Vest ${design_file_paths}/rm_matrix.txt ${design_file_paths}/design.grp
	fi
fi
mkdir ${output_directory}
mkdir ${output_directory}/merged_data
wb_shortcuts -cifti-concatenate ${output_directory}/merged_data/all_data.dscalar.nii -from-file ${concscalarfile}
wb_command -cifti-separate ${output_directory}/merged_data/all_data.dscalar.nii COLUMN -volume-all ${output_directory}/merged_data/all_data_sub.nii -metric CORTEX_LEFT ${output_directory}/merged_data/data_L.func.gii -metric CORTEX_RIGHT ${output_directory}/merged_data/data_R.func.gii
cp `head -n 1 ${concfile}`/MNINonLinear/fsaverage_LR32k/*L.midthickness*surf.gii ${output_directory}/merged_data/L.midthickness.surf.gii
cp `head -n 1 ${concfile}`/MNINonLinear/fsaverage_LR32k/*R.midthickness*surf.gii ${output_directory}/merged_data/R.midthickness.surf.gii
for subj in `cat ${concfile}` ; do
    if [ -f ${subj}/MNINonLinear/fsaverage_LR32k/*L.midthickness*surf.gii ]; then
	if [ -f ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_va.shape.gii ]; then
		echo ${subj} LH shape file exists and will not be generated here
	else
    		wb_command -surface-vertex-areas ${subj}/MNINonLinear/fsaverage_LR32k/*L.midthickness*surf.gii ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_va.shape.gii
	fi
    fi
    if [ -f ${subj}/MNINonLinear/fsaverage_LR32k/*R.midthickness*surf.gii ]; then
	if [ -f ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_va.shape.gii ]; then
		echo ${subj} RH shape file exists and will not be generated here
	else
	    	wb_command -surface-vertex-areas ${subj}/MNINonLinear/fsaverage_LR32k/*R.midthickness*surf.gii ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_va.shape.gii
	fi
    fi
done
L_MERGELIST=""
R_MERGELIST=""
for subj in `cat ${concfile}` ; do
    L_MERGELIST="${L_MERGELIST} -metric ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_va.shape.gii"
    R_MERGELIST="${R_MERGELIST} -metric ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_va.shape.gii"
done
wb_command -metric-merge ${output_directory}/merged_data/L_midthick_va.func.gii ${L_MERGELIST}
wb_command -metric-merge ${output_directory}/merged_data/R_midthick_va.func.gii ${R_MERGELIST}
wb_command -metric-reduce ${output_directory}/merged_data/L_midthick_va.func.gii MEAN ${output_directory}/merged_data/L_area.func.gii
wb_command -metric-reduce ${output_directory}/merged_data/R_midthick_va.func.gii MEAN ${output_directory}/merged_data/R_area.func.gii
#the conversions below are only needed for octave -- MATLAB can handle compression internally
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/data_L.func.gii ${output_directory}/merged_data/data_L.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/data_R.func.gii ${output_directory}/merged_data/data_R.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/L_area.func.gii ${output_directory}/merged_data/L_area.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/R_area.func.gii ${output_directory}/merged_data/R_area.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/L.midthickness.surf.gii ${output_directory}/merged_data/L.midthickness.surf.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/R.midthickness.surf.gii ${output_directory}/merged_data/R.midthickness.surf.gii
#data files are prepped, the below prepares PALM configuration files for running palm.
echo "data is prepared, time to run PALM!"
mkdir ${output_directory}/PALManalysis
touch ${output_directory}/PALManalysis/L_func.cfg
touch ${output_directory}/PALManalysis/R_func.cfg
touch ${output_directory}/PALManalysis/VOL_func.cfg
echo " #Configuration file for PALM." >> ${output_directory}/PALManalysis/L_func.cfg
echo " #Configuration file for PALM." >> ${output_directory}/PALManalysis/R_func.cfg
echo " #Configuration file for PALM." >> ${output_directory}/PALManalysis/VOL_func.cfg
echo "# " `date` >> ${output_directory}/PALManalysis/L_func.cfg
echo "# " `date` >> ${output_directory}/PALManalysis/R_func.cfg
echo "# " `date` >> ${output_directory}/PALManalysis/VOL_func.cfg
echo "-i ${output_directory}/merged_data/data_L.func.gii" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-s ${output_directory}/merged_data/L.midthickness.surf.gii ${output_directory}/merged_data/L_area.func.gii" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-i ${output_directory}/merged_data/data_R.func.gii" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-s ${output_directory}/merged_data/R.midthickness.surf.gii ${output_directory}/merged_data/R_area.func.gii" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-i ${output_directory}/merged_data/all_data_sub.nii" >> ${output_directory}/PALManalysis/VOL_func.cfg
echo "-d ${design_file_paths}/design.mat" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-d ${design_file_paths}/design.mat" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-d ${design_file_paths}/design.mat" >> ${output_directory}/PALManalysis/VOL_func.cfg
echo "-t ${design_file_paths}/design.con" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-t ${design_file_paths}/design.con" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-t ${design_file_paths}/design.con" >> ${output_directory}/PALManalysis/VOL_func.cfg
if [ -f ${design_file_paths}/design.fts ]; then
    echo "-f ${design_file_paths}/design.fts" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-f ${design_file_paths}/design.fts" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-f ${design_file_paths}/design.fts" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
if [ -f ${design_file_paths}/design.grp ]; then
    echo "-eb ${design_file_paths}/design.grp" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-eb ${design_file_paths}/design.grp" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-eb ${design_file_paths}/design.grp" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
if ${TFCE_enabled}; then 
    echo "-T" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-T" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-T" >> ${output_directory}/PALManalysis/VOL_func.cfg
    echo "-tfce2D" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-tfce2D" >> ${output_directory}/PALManalysis/R_func.cfg
fi
if ${cluster_inference}; then
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
echo "-n ${npermutations}" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-n ${npermutations}" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-n ${npermutations}" >> ${output_directory}/PALManalysis/VOL_func.cfg
if ${correction_contrast}; then
    echo "-corrcon" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-corrcon" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-corrcon" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
if ${twotail}; then
    echo "-twotail" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-twotail" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-twotail" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
if ${fdr_correction}; then
    echo "-fdr" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-fdr" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-fdr" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
echo "-o LEFT_CORTEX" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-o RIGHT_CORTEX" >> ${output_directory}/PALManalysis/R_func.cfg
echo "-o VOLUME" >> ${output_directory}/PALManalysis/VOL_func.cfg
#the instructions below will run PALM on each of the three datasets
touch ${output_directory}/palm_instructions.txt
echo "PALM files are prepared. To run palm follow these steps:"
echo " 1) cd ${output_directory}/PALManalysis"
echo " 2) palm L_func.cfg"
echo " 3) palm R_func.cfg"
echo " 4) palm VOL_func.cfg"
echo "For efficiency, it is recommended to run palm for the three cfg files (L,R,VOL) in separate processes."
echo "PALM files are prepared. To run palm follow these steps:" >> ${output_directory}/palm_instructions.txt
echo " 1) cd ${output_directory}/PALManalysis" >> ${output_directory}/palm_instructions.txt
echo " 2) palm L_func.cfg" >> ${output_directory}/palm_instructions.txt
echo " 3) palm R_func.cfg" >> ${output_directory}/palm_instructions.txt
echo " 4) palm VOL_func.cfg" >> ${output_directory}/palm_instructions.txt
echo "For efficiency, it is recommended to run palm for the three cfg files (L,R,VOL) in separate processes." >> ${output_directory}/palm_instructions.txt
if ${run_palm}; then
	pushd ${output_directory}/PALManalysis
	palm L_func.cfg
	palm R_func.cfg
	palm VOL_func.cfg
	CreatePALMCIFTIMaps.sh $1
	popd
fi
