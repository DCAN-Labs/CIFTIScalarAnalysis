function FDACiftiScalar(concfile,age,id,varargin)
%FDACiftiScalar prepares and runs CIFTI scalar data through the FDA trajectory analysis 
%%%%%
%
%
addpath(genpath('/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis'));
addpath(genpath('/group_shares/PSYCH/code/external/utilities/fdaM'));
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('wb_command')
                    wb_command = varargin{i+1};
                case('filename')
                    filename = varargin{i+1};
                case('roundfactor')
                    roundfactor = varargin{i+1};
                case('norder_data')
                    norder_data = varargin{i+1};
                case('norder_error')
                    norder_err = varargin{i+1};
                case('number_knots')
                    nknots = varargin{i+1};
                case('save_data')
                    output_file = varargin{i+1};
                    save_data = 1;
                case('EDA')
                    data_rangevector = varargin{i+1};
                    EDA = 1;
                case('time_multiplier')
                    timemulti = varargin{i+1};
                case('time_range')
                    time_range = varargin{i+1};
                case('time_range_flex')
                    time_range_flex = varargin{i+1};
                case('piecewise_sampling')
                    piecewise_sampling = 1;
                case('scatterplusmean')
                    plottype=2;
                case('meanonly')
                    plottype=3;
            end
        end
    end
end
%%load initial data
[scalar_data,cifti_filenames] = ReadCiftisIntoMATLAB(concfile,'wb_command',wb_command,'filename',strcat(output_directory,'/scalar_data.mat'));
%%if z transform is enabled (default) transform r values to z scores
if (z_transform_flag)
    zdata = rtoz(scalar_data);
else
    zdata = scalar_data;
end
sparse_data = [id age zdata];
GenerateFDACoeffMatrix(sparse_data,2,1,'roundfactor',roundfactor,'norder_data',norder_data,'norder_error',norder_err,'number_knots',number_knots,'save_data',strcat(output_file,'/FDAcoeff_results.mat'),'EDA',data_rangevector,'time_range',time_range,'time_range_flex',time_range_flex,'piece');
end

