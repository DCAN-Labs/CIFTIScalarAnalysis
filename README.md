ClusterScalarAnalysis is a suite of MATLAB tools used to perform analysis on CIFTI scalar data. It also includes utilities to handle importing CIFTIs into MATLAB.
Wrappers written in bash can be used to execute MATLAB utitlies from a command line.
# FUNCTIONS #

[scalar_data,filenames] = ReadCiftisIntoMATLAB('/path/to/file.conc','wb_command','/path/to/wb_command','filename','/path/to/output.mat') -- Reads a list of scalar cifti files into MATLAB and produces a matrix.

[design_mat,contrast_mat,ftest_mat,sub_mat]=PalmReader(20,'AnalysisType','anova','SaveOutput','/path/to/output/','Groups',[ 1 1 0 0...;0 0 2 1...]... ...,'NumFactors',2,'LevelsPerFactor',[2 2]) -- Generates design files for FSL PALM using a simpler parser.

RFCiftiScalars('/path/to/file.conc',[1 0 1 0...],'/path/to/output/files',0.6,1000,200,1,500,'wb_command','wb_command','LowDensity',0.05,'StepDensity',0.01,'HighDensity',0.1,'EDA',0.5,'PCA',1000,'MatchGroups','TreeBagsOff') -- Loads CIFTI scalar data from a list of concfiles and runs the RF analysis package on them.