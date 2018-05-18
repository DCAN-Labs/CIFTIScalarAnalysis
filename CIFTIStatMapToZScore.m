function CIFTIStatMapToZScore(varargin)
%CIFTIStatMapToZscore zscore transforms a raw CIFTI statistical map
%   Detailed explanation goes here
matlab_ciftipath='/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
matlab_giftipath='/mnt/max/shared/code/external/utilities/gifti-1.6';
ciftipath='/mnt/max/shared/code/internal/utilities/CIFTI/';
wb_command='wb_command';
output_data='adahn.dscalar.nii';
for i = 1:size(varargin,2)
    if ischar(varargin{i})
        switch(varargin{i})
            case('InputCIFTI')
                input_data=varargin{i+1};
            case('MatlabCIFTI')
                matlab_ciftipath=varargin{i+1};
            case('MatlabGIFTI')
                matlab_giftipath=varargin{i+1};
            case('CIFTIPath')
                ciftipath=varargin{i+1};
            case('WorkbenchCommand')
                wb_command=varargin{i+1};
            case('OutputCIFTI')
                output_data=varargin{i+1};
        end
    end
end
%addpaths here
addpath(genpath(matlab_ciftipath))
addpath(genpath(matlab_giftipath))
addpath(genpath(ciftipath))
%load data using workbench command
cifti_raw = ciftiopen(input_data,wb_command);
rawdata = cifti_raw.cdata;
cifti_new = cifti_raw;
cifti_new.cdata = (rawdata - mean(rawdata))/std(rawdata);
ciftisave(cifti_new,output_data,wb_command);
end

