#! /bin/bash
source $1
mkdir ${output_directory}
mkdir ${output_directory}/merged_data
wb_shortcuts -cifti-concatenate ${output_directory}/merged_data/all_data.dscalar.nii -from-file ${concscalarfile}
wb_command -cifti-separate ${output_directory}/merged_data/all_data.dscalar.nii -volume-all ${output_directory}/merged_data/all_data_sub.nii -metric CORTEX_LEFT ${output_directory}/merged_data/data_L.func.gii -metric CORTEX_RIGHT ${output_directory}/merged_data/data_R.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/data_L.func.gii ${output_directory}/merged_data/data_L.func.gii
wb_command -gifti-convert BASE64_BINARY ${output_directory}/merged_data/data_R.func.gii ${output_directory}/merged_data/data_R.func.gii
for subj in `cat ${concfile}` ; do
    wb_command -surface-vertex-areas ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_surf.gii ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_va.shape.gii
    wb_command -surface-vertex-areas ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_surf.gii ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_va.shape.gii
done
L_MERGELIST=""
R_MERGELIST=""
for subj in `cat ${concfile}` ; do
    L_MERGELIST="${L_MERGELIST} -metric ${subj}/MNINonLinear/fsaverage_LR32k/L_midthick_va.shape.gii"
    R_MERGELIST="${R_MERGELIST} -metric ${subj}/MNINonLinear/fsaverage_LR32k/R_midthick_va.shape.gii"
done
wb_command -metric_merge ${output_directory}/merged_data/L_midthick_va.func.gii ${L_MERGELIST}
wb_command -metric_merge ${output_directory}/merged_data/R_midthick_va.func.gii ${R_MERGELIST}
wb_command -metric-reduce ${output_directory}/merged_data/L_midthick_va.func.gii MEAN L_area.func.gii
wb_command -metric-reduce ${output_directory}/merged_data/R_midthick_va.func.gii MEAN R_area.func.gii

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
echo "" `date` >> ${output_directory}/PALManalysis/L_func.cfg
echo "" `date` >> ${output_directory}/PALManalysis/R_func.cfg
echo "" `date` >> ${output_directory}/PALManalysis/VOL_func.cfg
echo "-i ${output_directory}/merged_data/data_L.func.gii" >> ${output_directory}/PALManalysis/L_func.cfg
echo "-i ${output_directory}/merged_data/data_R.func.gii" >> ${output_directory}/PALManalysis/R_func.cfg
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
    echo "-tfce_H ${cluster_TFCE_height}" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-tfce_E ${cluster_TFCE_extent}" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-tfce_C ${cluster_TFCE_clustersize}" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
if ${cluster_inference}; then
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/L_func.cfg
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/R_func.cfg
    echo "-C ${cluster_threshold_Z}" >> ${output_directory}/PALManalysis/VOL_func.cfg
fi
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
pushd ${output_directory}/PALManalysis
palm L_func.cfg
palm R_func.cfg
palm VOL_func.cfg
popd
