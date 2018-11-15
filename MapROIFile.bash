#!/bin/bash
source ${1}
template_file=`head -n 1 ${dtseries_concfile}`
${WB_command} -cifti-label-to-roi ${labelfile} ROI_temp.dscalar.nii -key ${ROI_index}
${WB_command} -cifti-create-dense-from-template ${template_file} ${output_directory}/${roifile} -cifti ROI_temp.dscalar.nii

