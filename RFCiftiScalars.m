function RFCiftiScalars(concfile,outcome,output_directory,datasplit,nrepsCI,ntrees,nrepsPM,proximity_sub_limit,varargin)
%RFCiftiScalars prepares cifti scalar data for running a RF classification
%This code uses the Fair Lab Analysis and simple_infomap packages as
%dependencies
%%%%%%% INPUTS %%%%%%
% concfile -- a conc file listing N nifti inputs where N is the number of
% cases
% outcome -- a single column of length N representing the outcome per case
% output_directory -- the output_directory where data will be written
% datasplit -- the proportion of data to use for the RF
% nrepsCI -- the number of overall repetitions to perform
% nrepsPM -- the number of permutation repetitions per overall repetition
% proximity_sub_limit -- limits the size of the proxmat
%Optional inputs are the same as for the RF Analysis package. Please see
%the Analysis package for more details.
%%%%%USAGE%%%%%%
% RFCiftiScalars(concfile='/path/to/file.conc',outcome=[1 0 1 0...],output_directory='/path/to/output/files',datasplit=0.6,nrepsCI=1000,ntrees=200,nrepsPM=1,proximity_sub_limit=500,'wb_command',wb_command='wb_command','LowDensity',0.05,'StepDensity',0.01,'HighDensity',0.1,'EDA',0.5,'PCA',1000,'MatchGroups','TreeBagsOff');

%%set if on beast, comment out if on other systems
addpath(genpath('/group_shares/PSYCH/code/release/analysis/RFAnalysis'));
%%set if on rushmore, comment out if on other systems
%%addpath(genpath('/group_shares/PSYCH/code/release/analysis/RFAnalysis'));
%%choose your own path! comment out if on beast or rushmore
%addpath(genpath('/im/mr/meseeeks/lookatme'));

%create output_directory and set variables
mkdir(output_directory);
wb_command = 'wb_command';
regression = 0;
classification_method = 'Classification';
unsupervised = 0;
lowdensity = 0.2;
highdensity = 1;
stepdensity = 0.05;
runpcafirst = 0;
nPCAreps = 1000;
runEDA = 0;
var_threshold = 0.5;
z_transform_flag = 1;
unsupervised = 'NONE';
matchgroups = 'NONE';
treebag_save = 'NONE';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('wb_command')
                    wb_command = varargin{i+1};
                case('Regression')
                    Regression = 1;
                    classification_method='Regression';
                case('unsupervised')
                    unsupervised = 'unsupervised';
                case('LowDensity')
                    lowdensity = varargin{i+1};
                case('HighDensity')
                    highdensity = varargin{i+1};
                case('StepDensity')
                    stepdensity = varargin{i+1};
                case('PCA')
                    runpcafirst = 1;
                    nPCAreps = varargin{i+1};
                case('EDA')
                    runEDA = 1;
                    var_threshold = varargin{i+1};
                case('rtozoff')
                    z_transform_flag = 0;
                case('unsupervised')
                    unsupervised = 1;
                case('MatchGroups')
                    matchgroups = 'MatchGroups';
                case('TreebagsOff')
                    treebag_save = 'TreebagsOff';                
            end
        end
    end
end
%%load initial data
[scalar_data,cifti_filenames] = ReadCiftisIntoMATLAB(concfile,'wb_command',wb_command,'filename',strcat(output_directory,'/scalar_data.mat'));
%%load outcome variable
if isstruct(outcome)
    outvar = struct2array(load(outcome.path,outcome.variable));
else
    outvar = outcome;
end
if iscell(outvar)
    outvar = cell2mat(outvar);
end
%%if z transform is enabled (default) transform r values to z scores
if (z_transform_flag)
    zdata = rtoz(scalar_data);
else
    zdata = scalar_data;
end
%%if run EDA is selected, eliminate variables on the basis of normalized
%%variance (default value is 0.5)
if (runEDA)
    selected_data = zdata(:,abs(var(zdata)./mean(zdata)) > var_threshold);
else
    selected_data = zdata;
end
%if PCA is selected, perform a bootstrap PCA analysis to determine the
%number of components in the data, the scores from these components become
%the new RF_dataset
if (runpcafirst)
    for runnum = 1:nPCAreps
        boots_data = selected_data(randi(size(selected_data,1),size(selected_data,1),1),:);
        [~,~,boot_eigenval(:,runnum)] = pca(boots_data);
    end
    ncomponents = size(find(mean(boot_eigenval,2) - std(boot_eigenval,[],2)*2) > 1,1);
    [coeff,score,latent,tsquared,explained,mu] = pca(selected_data,'NumComponents',ncomponents);
    if (unsupervised)
        RF_dataset = score;
    else
        RF_dataset = [outvar score];
    end
    save(strcat(output_directory,'/pca_analysis.mat'),'coeff','score','latent','tsquared','explained','mu');
else
    if (unsupervised)
        RF_dataset = selected_data;
    else
        RF_dataset = [outvar selected_data];
    end
end
save(strcat(output_directory,'/RF_dataset.mat'),'RF_dataset');
ConstructModelTreeBag(RF_dataset,0,datasplit,nrepsCI,ntrees,nrepsPM,output_directory,proximity_sub_limit,classification_method,unsupervised,'LowDensity',lowdensity,'HighDensity',highdensity,'StepDensity',stepdensity,'useoutcomevariable',1,treebag_save,matchgroups);
end

