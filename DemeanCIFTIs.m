function DemeanCIFTIs(concfile,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
matlab_ciftipath = '/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
ciftipath = '/mnt/max/shared/code/internal/utilities/CIFTI/';
giftipath = '/mnt/max/shared/code/external/utilities/gifti-1.6';
wb_command='wb_command';
data_type = 'scalar';
within_networks = false;
large_file = false;
singlefile = 0;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('WB_command')
                    wb_command = varargin{i+1};
                case('filename')
                    filename = varargin{i+1};
                case('DataType')
                    data_type = varargin{i+1};
                case('Modules')
                    modules = varargin{i+1};
                case('WithinNetworks')
                    within_networks = true;
                case('v73')
                    large_file = true;
                case('MatlabCiftiPath')
                    matlab_ciftipath = varargin{i+1};
                case('CiftiPath')
                    ciftipath = varargin{i+1};
                case('GiftiPath')
                    giftipath = varargin{i+1};
                case('SingleFile')
                    singlefile = 1;
            end
        end
    end
end
addpath(genpath(matlab_ciftipath));
addpath(genpath(ciftipath));
addpath(genpath(giftipath));
if singlefile == 0
    fid = fopen(concfile);
    stuff = textscan(fid,'%s');
    filenames = stuff{1};
elseif singlefile == 1
    filenames{1} = concfile;
end
nsubs = length(filenames);
cifti_data = ReadCiftisIntoMATLAB(concfile,varargin);
demean_cifti_data = cifti_data - (mean(cifti_data,1));
for current_sub = 1:nsubs
    temp_cifti = ciftiopen(filenames{current_sub},wb_command);
    new_cifti = [ filenames{current_sub} '.demean.dscalar.nii'];
    temp_cifti.cdata = demean_cifti_data(current_sub,:)';
    ciftisave(temp_cifti,new_cifti,wb_command);
end

