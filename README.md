# FSL Palm
* A general overview of PALm can be found [here:](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM)
* In short, PALM runs general linear models on neuroimaging data. It is similar to FSL's randomize command, with the added capability of permutation testing within hierarchical models (see [Winkler, 2014](https://www.ncbi.nlm.nih.gov/pubmed/24530839)
* The package of scripts you will be working with is located across DCAN Lab servers at **~/code/internal/analyses/CIFTIScalarAnalysis**

## Setup: 
	* Set up conc files. 
		* One should point to subject folders, with one subject on each line (e.g., **/home/exacloud/lustre1/fnl_lab/data/HCP/processed/uo_tds/113/visit/HCP_release_20170910_v1.1/113**).
		* The second should point to dscalars (e.g, **/home/exacloud/lustre1/fnl_lab/data/HCP/processed/uo_tds/329/visit/HCP_release_20170910_v1.1/329/MNINonLinear/Results/329_L_amyg_ten_perc_mask_dscalar.dtseries.nii**)
	* Add paths to your bashrc profile.

### Exacloud

Paths to add to your bashrc profile are

```bash
export PATH=$PATH:/home/exacloud/lustre1/fnl_lab/code/external/palm/
export PATH=$PATH:/home/exacloud/lustre1/fnl_lab/code/internal/analyses/CIFTIScalarAnalysis/
export PATH=/home/exacloud/lustre1/fnl_lab/code/external/utilities/wb_shortcuts/:$PATH
export PATH=$PATH:/home/exacloud/lustre1/fnl_lab/code/external/utilities/workbench-1.2.3-HCP/bin_rh_linux64/
export PATH=$PATH:/home/exacloud/lustre1/fnl_lab/code/external/octave/octave_bin/bin
export PATH=/home/exacloud/lustre1/fnl_lab/code/external/utilities/exahead1-anaconda2/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/exacloud/lustre1/fnl_lab/code/external/SuiteSparse/SuiteSparse/lib:/home/exacloud/lustre1/fnl_lab/code/external/utilities/arpack/lib
```

### Rushmore

Paths to add to your bashrc profile are

```bash
# Note: I think there are a few extraneous paths here...

# added by Anaconda2 4.0.0 installer
export PATH="/home/shannon/anaconda2/bin:$PATH"

export PATH="/mnt/max/shared/projects/FAIR_users/Robert/plink_v1_9:$PATH"
export PATH="/mnt/max/shared/projects/FAIR_users/Robert/Haploview:$PATH"
export PATH="/mnt/max/shared/projects/FAIR_users/Robert/gPLINK2.jar:$PATH"
export PATH="/mnt/max/shared/projects/FAIR_users/Robert/Magma:$PATH"
export PATH="/mnt/max/shared/projects/FAIR_users/Robert/Magma_1.07_beta:$PATH"
export PATH="/mnt/max/shared/code/internal/analyses/CIFTIScalarAnalysis/:$PATH"
export PATH="/mnt/max/shared/code/external/analyses/PALM/:$PATH"
export PATH="/mnt/max/shared/code/external/utilities/wb_shortcuts/:$PATH"
export PATH="/mnt/max/shared/projects/FAIR_users/Robert/qctool_v1.4/qctool_v1.4-linux-x86_64:$PATH"
export PATH="/mnt/max/software/mplus/8:$PATH"
# make colors pop!

LS_COLORS=$LS_COLORS:'di=1;35'
export LS_COLORS

export FREESURFER_HOME=/usr/local/freesurfer
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
umask 002
```

## 1. Run PalmReader.m on rushmore. 
This script creates design, contrast, F-test, and subject matrices.

```bash
# Parameters - read PalmReader.m to see all of the options!
PalmReader(ncases, 'AnalysisType', 'AnalysisType_option', ... , 'SaveOutput', 'SaveOutput_path')

# Example: Includes the "group" option: two-sample t-test on 22 subjects, where 0 and 1 indicates group membership for each subject
PalmReader(22, 'AnalysisType', 'two_sample_test', 'Groups', [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1]', 'SaveOutput', '/mnt/max/shared/projects/uo_tds/palm')
```

### Exacloud
* Follow up step: move rushmore output from PalmReader.m to Exacloud. Possible location: **~/projects/[your_project_folder]/palm/**


## 2. PrepCiftisForPALM
* Parameters file: well documented at **~/code/internal/analyses/CIFTIScalarAnalysis/parameter_examplefile.params**
* Outputs L_func.cfg, R_func.cfg, and VOL_func.cfg files
* Command is **PrepCIFTIsForPALM.sh [path_to_params]**
* Current bug (as of 05/11/2018): re-running this script appends new configurations to the func.cfg files. Unless deleted, these extra runs will cause Palm to run very, very slowly.

## 3. Run PALM on slurm

For each model, PALM needs to be run separately for each hemisphere, as well as for the subcortical volumes (optional). 

### Exacloud 

```bash
srun --cpus-per-task 1 --mem-per-cpu 2G --partition exacloud --time 1-12:0 palm L_func.cfg
srun --cpus-per-task 1 --mem-per-cpu 2G --partition exacloud --time 1-12:0 palm R_func.cfg
srun --cpus-per-task 1 --mem-per-cpu 2G --partition exacloud --time 1-12:0 palm VOL_func.cfg
```

### Rushmore
On Rushmore, run the command directly, e.g., **palm L_func.cfg** 

## 4. Create PALM Ciftis
Under construction





# Older docmentation 

ClusterScalarAnalysis is a suite of MATLAB tools used to perform analysis on CIFTI scalar data. It also includes utilities to handle importing CIFTIs into MATLAB.

Wrappers written in bash can be used to execute MATLAB utitlies from a command line.
# FUNCTIONS #

[scalar_data,filenames] = ReadCiftisIntoMATLAB('/path/to/file.conc','wb_command','/path/to/wb_command','filename','/path/to/output.mat') -- Reads a list of scalar cifti files into MATLAB and produces a matrix.

[design_mat,contrast_mat,ftest_mat,sub_mat]=PalmReader(20,'AnalysisType','anova','SaveOutput','/path/to/output/','Groups',[ 1 1 0 0...;0 0 2 1...]... ...,'NumFactors',2,'LevelsPerFactor',[2 2]) -- Generates design files for FSL PALM using a simpler parser.

RFCiftiScalars('/path/to/file.conc',[1 0 1 0...], '/path/to/output/files',0.6,1000,200,1,500,'wb_command','wb_command','LowDensity',0.05,'StepDensity',0.01,'HighDensity',0.1,'EDA',0.5,'PCA',1000,'MatchGroups','TreeBagsOff') -- Loads CIFTI scalar data from a list of concfiles and runs the RF analysis package on them.

FDACiftiScalar('/path/to/file.conc',agedata,iddata,'norder_data',4,'norder_err',3,'number_knots',4,'piecewise_sampling','EDA',[-1 1],'time_range',[8 14],'save_data','/path/to/output/') -- Loads CIFTI data and performs a trajectory analysis on each greyordinate.

PrepCIFTIsForPALM.sh parameter_examplefile.params -- prepares CIFTI files for use with PALM, must run PalmReader or otherwise produce design files in order to run PALM.
