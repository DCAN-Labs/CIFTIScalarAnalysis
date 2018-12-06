function GenerateCIFTISeedMaps(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
matlab_ciftipath = '/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
ciftipath = '/mnt/max/shared/code/internal/utilities/CIFTI/';
giftipath = '/mnt/max/shared/code/external/utilities/gifti-1.6';
wb_command='wb_command';
extraction_type = 'mean';
FD = 0.2;
output_directory = './';
num_components = 1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('WB_command')
                    wb_command = varargin{i+1};
                case('OutputDirectory')
                    output_directory = varargin{i+1};
                case('ExtractionType')
                    extraction_type = varargin{i+1};
                case('MatlabCiftiPath')
                    matlab_ciftipath = varargin{i+1};
                case('CiftiPath')
                    ciftipath = varargin{i+1};
                case('GiftiPath')
                    giftipath = varargin{i+1};
                case('DtseriesConcFile')
                    dtseries_concfile = varargin{i+1};
                case('MotionConcFile')
                    motion_concfile = varargin{i+1};
                case('DscalarROIFile')
                    dscalar_roifile = varargin{i+1};
                case('FD')
                    FD = varargin{i+1};
                case('NumComponents')
                    num_components = varargin{i+1};
            end
        end
    end
end
addpath(genpath(matlab_ciftipath));
addpath(genpath(ciftipath));
addpath(genpath(giftipath));
[dtseries_data,filenames] = ReadCiftisIntoMATLAB(dtseries_concfile,'WB_command',wb_command,'DataType','dtseries');
motion_data = ReadMotionMatFiles(motion_concfile,'FD',FD);
ROI_file = ciftiopen(dscalar_roifile,wb_command);
ROI_file_split = split(dscalar_roifile,'/');
ROI_filename = ROI_file_split(end);
ROI_data = ROI_file.cdata;
nsubs = length(dtseries_data);
for current_sub = 1:nsubs
    dtseries_sub = dtseries_data{current_sub}.cdata;
    dtseries_sub = dtseries_sub(:,motion_data{current_sub}==0);
    dtseries_sub_ROI = dtseries_sub(ROI_data==1,:);
    switch(extraction_type)
        case('pca')
            [components,~,~,~,varexplained] = pca(dtseries_sub_ROI','NumComponents',num_components);
            pca_dtseries_ROI = dtseries_sub_ROI*0;
            for curr_component = 1:num_components
                pca_dtseries_ROI = pca_dtseries_ROI + (dtseries_sub_ROI.*components(:,curr_component)).*(varexplained(curr_component)/100);
            end
            new_dtseries_ROI = mean(pca_dtseries_ROI,1);
        case('mean')
            new_dtseries_ROI = mean(dtseries_sub_ROI,1);
    end
    sub_scalar_corr = corr(dtseries_sub',new_dtseries_ROI');
    file_split = split(filenames{current_sub},'/');
    new_filename = file_split(end);
    ts_file_output = char(strcat(output_directory,'/',ROI_filename,'_',extraction_type,'_timeseries.csv'));
    dlmwrite(ts_file_output,new_dtseries_ROI');
    ROI_file.cdata = sub_scalar_corr;
    file_output = char(strcat(output_directory,'/',new_filename,'_corr_via_',ROI_filename,'.dscalar.nii'));
    ciftisave(ROI_file,file_output,wb_command);
end

