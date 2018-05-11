function [scalar_data,filenames] = ReadCiftisIntoMATLAB(concfile,varargin)
%ReadCiftisIntoMATLAB will read a list of scalar CIFTIs into matlab via a conc file
%%%%%%%% INPUTS %%%%%%
% concfile -- a conc file listing N nifti inputs where N is the number of
% cases
% *filename* -- an optional input, when specified, include a string
% containing the full path to the output file. Scalar data will be stored
% as a MATLAB .mat file
% *wb_command* -- an optional input used to specify the path and name of
% the wb_command. Use if it differs from "wb_command".
%%%%%%%% OUTPUTS %%%%%
% scalar_data -- a N by M scalar matrix where N is the number of cases and
% M is the number of greyordinates. This program makes no assumptions about
% the number of greyordinates save that they are identical between all
% cases.
% filenames -- a N by 1 cell matrix contaiing the full paths to each conc
% file in the same order as the scalar_data. Useful for double checking
% that the order is correct.
%%%%%%%% USAGE %%%%%%%
% [scalar_data,filenames] = ReadCiftisIntoMATLAB(concfile='/path/to/file.conc','wb_command',wb_command='/path/to/wb_command','filename',filename='/path/to/output.mat')

%%set if on beast, comment out if on other systems
%addpath(genpath('/group_shares/PSYCH/code/external/utilities/Matlab_CIFTI'));
%addpath(genpath('/group_shares/PSYCH/code/development/utilities/HCP_Matlab/CIFTIS'));
%addpath(genpath('/group_shares/PSYCH/code/development/utilities/gifti-1.6'));
%%set if on rushmore, comment out if on other systems
addpath(genpath('/mnt/max/shared/code/external/utilities/Matlab_CIFTI'))
addpath(genpath('/mnt/max/shared/code/internal/utilities/CIFTI/'))
addpath(genpath('/mnt/max/shared/code/external/utilities/gifti-1.6'))
%%choose your own path! comment out if on beast or rushmore
%addpath(genpath('/this/Path/is/my/path/'));
%addpath(genpath('/this/path/is/your/path'));
%addpath(genpath('/im/mr/meseeeks/lookatme'));
wb_command='wb_command';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('wb_command')
                    wb_command = varargin{i+1};
                case('filename')
                    filename = varargin{i+1};
            end
        end
    end
end
fid = fopen(concfile);
stuff = textscan(fid,'%s');
filenames = stuff{1};
nsubs = length(filenames);
for current_sub = 1:nsubs
    temp_cifti = ciftiopen(filenames{current_sub},wb_command);
    if current_sub == 1
        nscalarpts = size(temp_cifti.cdata,1);
        scalar_data = zeros(nsubs,nscalarpts);
    end
    scalar_data(current_sub,:) = temp_cifti.cdata;
end
if exist('filename','var')
    save(filename,'scalar_data', 'filenames');
end
end

