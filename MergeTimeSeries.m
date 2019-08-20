function MergeTimeSeries(varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
output_file = 'thenamelessone';
wb_command = 'wb_command';
output_motion_file = 'thenamelessone_motion_mat';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('WB_command')
                    wb_command = varargin{i+1};
                case('TimeSeriesFiles')
                    tseries_fileinfo = varargin{i+1};
                case('MotionFiles')
                    motion_fileinfo = varargin{i+1};
                case('OutputFile')
					output_file = varargin{i+1};
                case('MotionOutputFile')
                    motion_output_file = varargin{i+1};
            end
        end
    end
end
if iscell(tseries_fileinfo)
    tseries_files = tseries_fileinfo;
else
    fid = fopen(tseries_fileinfo);
    stuff = textscan(fid,'%s');
    tseries_files = stuff{1};    
end
if iscell(motion_fileinfo)
    motion_files = motion_fileinfo;
else
    fid = fopen(motion_fileinfo);
    stuff = textscan(fid,'%s');
    motion_files = stuff{1};  
end
merge_command = [ wb_command ' -cifti-merge ' output_file];
for curr_tseries = 1:length(tseries_files)
    merge_command = [merge_command ' -cifti ' tseries_files{curr_tseries} ];
end
system(merge_command);
motion_repo = cell(length(motion_files),1)
for curr_motion = 1:length(motion_files)
    temp_motion = load(motion_files{curr_motion});
    motion_data = cell(length(temp_motion,1));
    for curr_threshold = 1:length(temp_motion)
        if curr_motion == 1
            motion_data{curr_threshold}.skip = temp_motion{curr_threshold}.skip;
            motion_data{curr_threshold}.epi_TR = temp_motion{curr_threshold}.epi_TR;
            motion_data{curr_threshold}.FD_threshold = temp_motion{curr_threshold}.FD_threshold;
            motion_data{curr_threshold}.frame_removal = temp_motion{curr_threshold}.frame_removal;
            motion_data{curr_threshold}.format_string = temp_motion{curr_threshold}.format_string;
            motion_data{curr_threshold}.total_frame_count = temp_motion{curr_threshold}.total_frame_count;
            motion_data{curr_threshold}.remaining_frame_count = temp_motion{curr_threshold}.remaining_frame_count;
            motion_data{curr_threshold}.remaining_seconds = temp_motion{curr_threshold}.remaining_seconds;
            motion_data{curr_threshold}.remaining_frame_mean_FD = temp_motion{curr_threshold}.remaining_frame_mean_FD;
        else
            motion_data{curr_threshold}.frame_removal(end+1:end+length(temp_motion{curr_threshold}.frame_removal)) = temp_motion{curr_threshold}.frame_removal;
            motion_data{curr_threshold}.format_string = [motion_data{curr_threshold}.format_string '+' temp_motion{curr_threshold}.format_string];
            motion_data{curr_threshold}.total_frame_count = motion_data{curr_threshold}.total_frame_count + temp_motion{curr_threshold}.total_frame_count;
            motion_data{curr_threshold}.remaining_frame_count = motion_data{curr_threshold}.remaining_frame_count + temp_motion{curr_threshold}.remaining_frame_count;
            motion_data{curr_threshold}.remaining_seconds = motion_data{curr_threshold}.remaining_seconds + temp_motion{curr_threshold}.remaining_seconds;
            motion_data{curr_threshold}.remaining_frame_mean_FD = motion_data{curr_threshold}.remaining_frame_mean_FD + temp_motion{curr_threshold}.remaining_frame_mean_FD;
        end
    end
end
for curr_threshold = 1:length(temp_motion)
    motion_data{curr_threshold}.remaining_frame_mean_FD = motion_data{curr_threshold}.remaining_frame_mean_FD/length(motion_files);
end
save(motion_output_file,motion_data);
    
          