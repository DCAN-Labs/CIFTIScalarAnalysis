#!/bin/bash
source $1
#separate dscalar file into separate volume,RH,and LH files
wb_command -cifti-separate ${dscalar_file}.dscalar.nii COLUMN -volume-all ${dscalar_file}_vol.nii -metric ${dscalar_file}_L.func.gii -metric CORTEX_RIGHT ${dscalar_file}_R.func.gii
#write parameter files for each of RH,LH and volume

#ready to run!
