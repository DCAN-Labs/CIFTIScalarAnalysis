function [random_designs] = RandDesign(ncases,nreps,varargin)
%RandDesign generates a series of design.mat files where each EV is
%selected from a random distribuiton
%   RandDesign can be used to aid in simulation studies for regression
%   problems
shuffletype='normal'; %default is to select data from a normal distribution
output_prefix = 'random';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if size(varargin{i},1) <= 1
            if ischar(varargin{i})
                switch(varargin{i})
                    case('normal')
                    	shuffletype = 'normal';
                    case('output_path')
                        output_path = varargin{i+1};
                    case('output_prefix')
                        output_prefix = varargin{i+1};
                end
            end
        end
    end
end
if exist('output_path','var')
    output_directory = strcat(output_path,'/design_perms');
else
    output_directory = 'design_perms';
end
mkdir(output_directory);
switch(shuffletype)
    case('normal')
        random_designs = zeros(ncases,nreps*2);
        random_design_base = randn(ncases,nreps);
        for curr_base = 1:nreps
            random_design_base(:,curr_base) = random_design_base(:,curr_base) - mean(random_design_base(:,curr_base));
        end
        random_designs(:,1:2:(nreps*2)-1) = random_design_base;
        random_designs(:,2:2:nreps*2) = random_design_base.*-1;
        count = 0;
        for current_rep = 1:2:(nreps*2)-1
            count = count + 1;
            temp_output_directory = strcat(output_directory,'/design_',num2str(count));
            mkdir(temp_output_directory);
            fid = fopen(strcat(temp_output_directory,'/',output_prefix,'_',num2str(count),'.txt'),'wt');
            fprintf(fid,'%f\t%f\n',random_designs(:,count:count+1)');
            fclose(fid);
            contrast_matrix = [1, 0;0, 1];
            fid = fopen(strcat(temp_output_directory,'/','contrast_matrix.txt'),'wt');
            fprintf(fid,'%d\t%d\n',contrast_matrix');
            fclose(fid);
        end

end
end

