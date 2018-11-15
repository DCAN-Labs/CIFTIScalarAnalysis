#!/bin/bash

#GenerateCIFTISeedMaps_params.bash is a parameter file for the wrapper: GenerateCIFTISeedMaps_wrapper.sh
#USAGE: GenerateCIFTISeedMaps_wrapper.sh GenerateCIFTISeedMaps_params.bash
#Please note that the parameter file can be renamed to anything

#Below are the parameters that need to be set to run the program

##INPUTS########################################################################################################

#dtseries_concfile specifies the dtseries.nii files needed to generate both the ROI timecourse and the seedmaps
dtseries_concfile=/mnt/max/shared/projects/FAIR_users/Feczko/projects/seedmap_demo/ADHD_dtseries_demo.conc

#motion_concfile specificies the power_2014_DF_only.mat files needed to perform motion censoring appropriately
motion_concfile=/mnt/max/shared/projects/FAIR_users/Feczko/projects/seedmap_demo/ADHD_motion_demo.conc

#labelfile is the path to the dlabel file to generate an ROI file
labelfile=/mnt/max/shared/ROI_sets/Surface_schemes/Human/Gordon/fsLR/Gordon.subcortical.32k_fs_LR.dlabel.nii

#ROI_index is a number that represents the ROI# to extract from the corresponding dlabel file this program will automatically generate an appropriate ROI file as a result
ROI_index=1

##TIMECOURSE EXTRACTION PARAMETERS##############################################################################

#FD is the frame displacement threshold for motion censoring to use when extracting the ROI timeseries AND generating a seedmap -- specified in millimeters
FD=0.2

#extraction_type is the type of ROI extraction to perform, currently can be either "pca" or a simple "mean"
extraction_type='mean'
	#if "pca" is selected, the num_components specifies how many principal components to use for generating timeseries, components are weighted by the percent variance explained
	num_components=1

##ENVIRONMENT PARAMETERS########################################################################################

#matlab command indicates the executable for calling matlab
matlab_command=matlab16b

#wb_command indicates the executable for running the workbench command -- may be a full path if needed
WB_command=wb_command

#matlab_cifti_path represents the path to the MATLAB_CIFTI package, one of three needed for full CIFTI manipulation within MATLAB
matlab_cifti_path=/mnt/max/shared/code/external/utilities/Matlab_CIFTI

#cifti_path represents the path to the CIFTI package, one of three needed for full CIFTI manipulation within MATLAB
cifti_path=/mnt/max/shared/code/internal/utilities/CIFTI/

#gifti_path represents the path to the GIFTI package, one of three needed for full CIFTI manipulation within MATLAB
gifti_path=/mnt/max/shared/code/external/utilities/gifti-1.6

#repository represents the path to the CIFTIScalarAnalysis repository
repository=/mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/CIFTIScalarAnalysis/

##OUTPUT PARAMETERS##############################################################################################

#roifile represents the name of the roi file that is written when extracted from the labelfile -- can be found in the output directory specified below
roifile=ROI1.dscalar.nii

#output_directory where the output seedmaps will be saved
output_directory=/mnt/max/shared/projects/FAIR_users/Feczko/projects/seedmap_demo/output_seedmaps/

