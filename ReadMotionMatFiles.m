function subject_motion_mat = ReadMotionMatFiles(concfile,varargin)
%ReadMotionMatFiles reads in motion mat data and outputs a large motion
%matrix for vectorized thresholding -- speeds up correlation calculations
%   Detailed explanation goes here
large_file = false;
FD = 0.2;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('filename')
                    filename = varargin{i+1};
                case('v73')
                    large_file = true;
                case('FD')
                    FD = varargin{i+1};
            end
        end
    end
end
frame_index = (FD*100) + 1;
fid = fopen(concfile);
stuff = textscan(fid,'%s');
filenames = stuff{1};
nsubs = length(filenames);
subject_motion_mat = cell(nsubs,1);
for current_sub = 1:nsubs
    motion_data = load(filenames{current_sub},'motion_data');
    subject_motion_mat{current_sub} = motion_data.motion_data{frame_index}.frame_removal;
end
if exist('filename','var')
    if large_file
        save(filename,'scalar_data', 'filenames','-v7.3');               
    else
        save(filename,'scalar_data', 'filenames');
    end
end
end
