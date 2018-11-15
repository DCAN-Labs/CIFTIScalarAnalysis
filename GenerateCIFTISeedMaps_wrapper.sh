#!/bin/bash

#GenerateCIFTISeedMaps_wrapper.sh is used to generate seed maps for a given ROI from a labelfile, taking into account proper motion censoring. A parameter file is sourced and instructions for the parameter file can be found in GenerateCIFTISeedMaps_params.bash
#USAGE: GenerateCIFTISeedMaps_wrapper.sh GenerateCIFTISeedMaps_params.bash

source ${1}

#first, generate the ROI using MapROIFile.bash
${repository}/MapROIFile.bash ${1}


${matlab_command} -nodisplay -nosplash -r "addpath(genpath('"${repository}"')); GenerateCIFTISeedMaps('WB_command','"${WB_command}"','OutputDirectory','"${output_directory}"','ExtractionType','"${extraction_type}"','MatlabCiftiPath','"${matlab_cifti_path}"','CiftiPath','"${cifti_path}"','GiftiPath','"${gifti_path}"','DtseriesConcFile','"${dtseries_concfile}"','MotionConcFile','"${motion_concfile}"','DscalarROIFile','"${output_directory}/${roifile}"','FD',"${FD}",'NumComponents',"${num_components}");"

