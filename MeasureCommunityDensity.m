function [community_density] = MeasureCommunityDensity(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tic
matlab_ciftipath = '/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
ciftipath = '/mnt/max/shared/code/internal/utilities/CIFTI/';
giftipath = '/mnt/max/shared/code/external/utilities/gifti-1.6';
wb_command='wb_command';
distance_thresh = 8;
normed = 0;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('WB_command')
                    wb_command = varargin{i+1};
                case('filename')
                    filename = varargin{i+1};
                case('CiftiDscalar')
                    cifti_dscalar = varargin{i+1};
                case('CiftiDistance')
                    cifti_distance = varargin{i+1};
                case('MatlabCiftiPath')
                    matlab_ciftipath = varargin{i+1};
                case('CiftiPath')
                    ciftipath = varargin{i+1};
                case('GiftiPath')
                    giftipath = varargin{i+1};
                case('DistanceThreshold')
                    distance_thresh = varargin{i+1};
                case('Normed')
                    normed = 1;
            end
        end
    end
end
addpath(genpath(matlab_ciftipath));
addpath(genpath(ciftipath));
addpath(genpath(giftipath));
if ischar(cifti_dscalar)
    dscalar_loaded = ciftiopen(cifti_dscalar,wb_command);
    cifti_dscalar = dscalar_loaded.cdata;
end
if ischar(cifti_distance)
    if strcmp(cifti_distance(end-3:end),'.mat')
        cifti_distance = cell2mat(struct2cell(load(cifti_distance,'distances')));
    else
        distance_loaded = ciftiopen(cifti_distance,wb_command);
        cifti_distance = distance_loaded.cdata;
        clear distance_loaded
    end
end
thresh_matrix = cifti_distance <= distance_thresh;
clear cifti_distance
thresh_matrix = single(thresh_matrix);
community_thresh = repmat(cifti_dscalar,1,length(cifti_dscalar)).*thresh_matrix;
clear thresh_matrix
community_density = single(zeros(length(community_thresh),1));
for curr_point = 1:length(community_density)
    disp(['Caluclating density for index #' num2str(curr_point)]);
    community_density(curr_point,1) = sum(unique(community_thresh(:,curr_point)) > 0);
end
if normed
    community_density = community_density./max(community_density);
end
clear community_thresh
if exist('filename','var')
    cifti_dscalar(:,1) = community_density;
    dscalar_loaded.cdata = cifti_dscalar;
    ciftisave(dscalar_loaded,filename,wb_command);
end
toc
end




