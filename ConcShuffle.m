function [filename_orders, filenames] = ConcShuffle(concfile,concscalarfile,nreps,varargin)
%ConcShuffle generates a series of concfiles where the participants are shuffled 
%This is done so that the same parameters for a palm file (e.g. from
%PalmReader) can be used to run a large set of simulations.
%   Currently ConcShuffle is only built for:
%
%       -two sample comparison of means (e.g. t-test or linear model)
%
%%%%%%%INPUTS%%%%%%%%%
%
%
%%%%%%%OUTPUTS%%%%%%%%
%
%
%%%%%%%%USAGE%%%%%%%%%
%


shuffletype = 'bag';
output_prefix = 'concfile';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if size(varargin{i},1) <= 1
            if ischar(varargin{i})
                switch(varargin{i})
                    case('permute')
                    	shuffletype = 'permute';
                    case('bootstrap')
                        shuffletype = 'bootstrap';
                    case('output_path')
                        output_path = varargin{i+1};
                    case('output_prefix')
                        output_prefix = varargin{i+1};
                end
            end
        end
    end
end
fid = fopen(concfile);
stuff = textscan(fid,'%s');
filenames = stuff{1};
nfiles = length(filenames);
clear stuff
fclose(fid);
fid = fopen(concscalarfile);
stuff = textscan(fid,'%s');
filenames_scalar = stuff{1};
fclose(fid);
switch(shuffletype)
    case('bootstrap')
        filename_orders = randi(nfiles,nfiles,nreps);
    case('permute')
        filename_orders = zeros(nfiles,nreps);
        for rep = 1:nreps
            filename_orders(:,rep) = randperm(nfiles,nfiles);
        end
    case('bag')
        filename_orders = zeros(nfiles,nreps);
        for rep = 1:nreps
            temp_shuffle = randperm(nfiles,nfiles);
            new_order = temp_shuffle.';
            new_order(1:round(nfiles/2),1) = temp_shuffle(randi(round(nfiles/2),round(nfiles/2),1));
            new_order(round(nfiles/2)+1:end,1) = temp_shuffle(randi(nfiles-round(nfiles/2),nfiles-round(nfiles/2),1)+round(nfiles/2));
            filename_orders(:,rep) = new_order;
        end
end
if exist('output_path','var')
    output_directory = strcat(output_path,'/conc_perms');
else
    output_directory = 'conc_perms';
end
mkdir(output_directory);
for current_rep = 1:nreps
    fid = fopen(strcat(output_directory,'/',output_prefix,'_',num2str(current_rep),'.conc'),'wt');
    fidb = fopen(strcat(output_directory,'/',output_prefix,'_',num2str(current_rep),'_scalar.conc'),'wt');
    for currfile = 1:nfiles
        fprintf(fid,'%s\n',filenames{filename_orders(currfile,current_rep)});
        fprintf(fidb,'%s\n',filenames_scalar{filename_orders(currfile,current_rep)});
    end
    fclose(fid);
end
end

