function [maxsize,clstat,sizes] = PalMPlusClusterDetection(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
matlab_ciftipath='/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
matlab_giftipath='/mnt/max/shared/code/external/utilities/gifti-1.6';
ciftipath='/mnt/max/shared/code/internal/utilities/CIFTI/';
palmpath='/mnt/max/shared/code/external/analyses/PALM';
fspath='/mnt/max/shared/code/external/utilities/freesurfer-5.3.0-HCP/';
wb_command='wb_command';
output_path='thenamelessone.dscalar.nii';
opts.npcmod=false;
opts.MV=false;
opts.forcemaskinter=false;
correct_pvalues = 0;
pvalue_correction = 0;
estimate_pvalues = 0;
nperms = 0;
permutation_test = 0;
null_distribution = 0;
znorm = 0;
zstr = 'cluster_detection';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            if ischar(varargin{i}) == 1 || max(size(varargin{i})) == 1
                switch(varargin{i})
                    case('InputCIFTI')
                        stat_file=varargin{i+1};
                    case('InputStructure')
                        struct_file=varargin{i+1};
                    case('CorrectionType')
                        correction_type=varargin{i+1};
                    case('CorrectionThresh')
                        threshold=varargin{i+1};
                    case('MatlabCIFTI')
                        matlab_ciftipath=varargin{i+1};
                    case('MatlabGIFTI')
                        matlab_giftipath=varargin{i+1};
                    case('CIFTIPath')
                        ciftipath=varargin{i+1};
                    case('WorkbenchCommand')
                        wb_command=varargin{i+1};
                    case('OutputCIFTI')
                        output_path=varargin{i+1};
                    case('StructureType')
                        structure_type=varargin{i+1};
                    case('PalmDir')
                        palmpath=varargin{i+1};     
                    case('FSPath')
                        fspath=varargin{i+1};
                    case('PvalueCorrection')
                        pvalue_correction = varargin{i+1};
                        if pvalue_correction ~= 0
                            correct_pvalues = 1;
                        end
                    case('EstimateCorrection')
                        cifti_test_statistic_file = varargin{i+1};
                        if strcmp(cifti_test_statistic_file,'NONE') == 0
                            correct_pvalues = 0; %estimation wipes out pvalue correction
                            estimate_pvalues = 1;
                        end
                    case('NPermutations')
                        nperms = varargin{i+1};
                        if nperms ~= 0
                            permutation_test = 1;
                            null_distribution = zeros(nperms,1);
                        end
                    case('ZNormalize')
                        znorm = 1;
                    case('OutputPrefix')
                        output_prefix=varargin{i+1};
                end
            end
        end
    end
end
if estimate_pvalues
    correct_pvalues = 0;
end
addpath(genpath(matlab_ciftipath))
addpath(genpath(ciftipath))
addpath(genpath(matlab_giftipath))
addpath(genpath(palmpath))
addpath(genpath(fspath))
%load data depending on parameters specified
switch(structure_type)
    case('volume')
        %load volume data
        hdr = load_nifti(stat_file);
        stat_map = hdr.vol;
        stat_map = abs(stat_map);
        %adjust flags
        plm.Yisvol=true;
        plm.Yisfac=false;
        plm.Yisvtx=false;
    case('surface')
        %load map
        if strcmp(stat_file(end-3:end),'.gii')
            save_gifti=1;
            stat_cifti = gifti(stat_file);
        elseif strcmp(stat_file(end-3:end),'.nii')
            stat_cifti = ciftiopen(stat_file,wb_command);
            save_gifti=0;
        else
            error('Invalid statistic map file specified as a surface file. The surface file must be specified as a CIFTI with a .nii or a GIFTI with a .gii extension');
        end
        stat_map = abs(stat_cifti.cdata); %using absolute values to ensure threshold is proper
        %load surface and calculate area/adjacency
        struct_gii=gifti(struct_file);
        S.fac = struct_gii.faces;
        S.vtx = struct_gii.vertices;
        if isfield(struct_gii,'mat')
            S.vtx = [S.vtx ones(size(S.vtx,1),1)];
            S.vtx = S.vtx * struct_gii.mat;
            S.vtx = S.vtx(:,1:3);
        end
        plm.Yadjacency{1} = palm_adjacency(S.fac,1);
        plm.Yarea{1} = palm_calcarea(S,1);
        plm.Yisvol=false;
        plm.Yisfac=true;
        plm.Yisvtx=true;
end
%if stat image contains zeros for pvalues, fix them here
if correct_pvalues
    stat_map(stat_map==0)=pvalue_correction;
end
if estimate_pvalues %if a corresponding test statistic file exists we can estimate pvalues instead of fixing them
    cifti_test_stat_image = ciftiopen(cifti_test_statistic_file,wb_command);
    test_stat = cifti_test_stat_image.cdata;
    zscored_stat = abs((test_stat - mean(test_stat))/std(test_stat));
    if znorm
        stat_map = 1 - normcdf(zscored_stat);
        zstr = 'znormed';
    else
        stat_map = 1 - normcdf(test_stat);
        zstr = 'non_znormed';
    end
end
%generate mask for stat image
plm.masks = cell(1,1);
plm.masks{1}.data = double(stat_map);
plm.masks{1}.data(isnan(plm.masks{1}.data)) = 1;
plm.masks{1}.data(isinf(plm.masks{1}.data)) = 1;
plm.masks{1}.data(plm.masks{1}.data==0)=1;
plm.masks{1}.data = logical(plm.masks{1}.data);
plm.nmasks=1;
size(stat_map)
size(plm.masks{1}.data)

%perform cluster analysis
switch(correction_type)
    case('extent')
        file_id='clustere';
        [maxsize,clstat,sizes]=palm_clustere(stat_map,1,threshold,opts,plm);
        if permutation_test
            sprintf('starting permutation test under random field theory assumptions')
            tic
            rng('shuffle');
            switch(structure_type)
                case('surface')
                    for permutation = 1:nperms
                        null_distribution(permutation,1) = palm_clustere(stat_map(randperm(length(stat_map))),1,threshold,opts,plm);
                    end                   
                case('volume')
                    for permutation = 1:nperms
                        null_distribution(permutation,1) = palm_clustere(stat_map(randperm(size(stat_map,1)),randperm(size(stat_map,2)),randperm(size(stat_map,3))),1,threshold,opts,plm);
                    end
            end
            null_distribution = sort(null_distribution);
            cell_null_distribution = cell(size(clstat));
            cell_null_distribution(:,:) = {null_distribution};
            cell_clstat = num2cell(clstat);
            pstat = cell2mat(cellfun(@check_null_distribution,cell_clstat,cell_null_distribution,'UniformOutput',0));
            toc
            sprintf('permutation test completed!')            
        end
    case('mass')
        file_id='clusterm';
        [maxsize,clstat,sizes]=palm_clusterm(stat_map,1,threshold,opts,plm);
        if permutation_test
            sprintf('starting permutation test under random field theory assumptions')
            tic
            rng('shuffle');
            for permutation = 1:nperms
                null_distribution(permutation,1) = palm_clusterm(stat_map(randperm(length(stat_map))),1,threshold,opts,plm);
            end                   
            null_distribution = sort(null_distribution);
            cell_null_distribution = cell(size(clstat));
            cell_null_distribution(:,:) = {null_distribution};
            cell_clstat = num2cell(clstat);
            pstat = cell2mat(cellfun(@check_null_distribution,cell_clstat,cell_null_distribution,'UniformOutput',0));
            toc
            sprintf('permutation test completed!')                      
        end        
    case('density')
        file_id='clusterd';
        [maxsize,clstat,sizes]=palm_clusterd(stat_map,1,threshold,opts,plm);
        if permutation_test
            sprintf('starting permutation test under random field theory assumptions') 
            tic
            rng('shuffle');
            for permutation = 1:nperms
                null_distribution(permutation,1) = palm_clusterd(stat_map(randperm(length(stat_map))),1,threshold,opts,plm);
            end                   
            null_distribution = sort(null_distribution);
            cell_null_distribution = cell(size(clstat));
            cell_null_distribution(:,:) = {null_distribution};
            cell_clstat = num2cell(clstat);
            pstat = cell2mat(cellfun(@check_null_distribution,cell_clstat,cell_null_distribution,'UniformOutput',0));
            toc
            sprintf('permutation test completed!')                      
        end        
    case('tippett')
        file_id='clustert';
        [maxsize,clstat,sizes]=palm_clustert(stat_map,1,threshold,opts,plm);
        if permutation_test
            sprintf('starting permutation test under random field theory assumptions')
            tic
            rng('shuffle');
            for permutation = 1:nperms
                null_distribution(permutation,1) = palm_clustert(stat_map(randperm(length(stat_map))),1,threshold,opts,plm);
            end                   
            null_distribution = sort(null_distribution);
            cell_null_distribution = cell(size(clstat));
            cell_null_distribution(:,:) = {null_distribution};
            cell_clstat = num2cell(clstat);
            pstat = cell2mat(cellfun(@check_null_distribution,cell_clstat,cell_null_distribution,'UniformOutput',0));
            toc
            sprintf('permutation test completed!')                      
        end        
    case('pivotal') %requires a different set of parameters, and isn't needed now, will be done later -- EF 4/13/18
    case('FDR_storey')
        pstat=stat_map;
        logpstat = -log10(stat_map);        
        file_id='FDR_storey';
        switch(structure_type)
            case('surface')
                clstat = mafdr(stat_map);
            case('volume')
                [lth,width]=size(stat_map);
                new_map=zeros(lth*width,1);
                new_map(:) = stat_map;
                clstat_reshaped = mafdr(new_map);
                clstat = reshape(clstat_reshaped,lth,width);
        end
    case('FDR_BH')
        file_id='FDRBH';
        pstat=stat_map;
        logpstat = -log10(stat_map);
        switch(structure_type)
            case('surface')
                clstat = mafdr(stat_map,'BHFDR',1);
            case('volume')
                [lth,width]=size(stat_map);               
                new_map=zeros(lth*width,1);
                new_map(:) = stat_map;
                clstat_reshaped = mafdr(new_map,'BHFDR',1);
                clstat = reshape(clstat_reshaped,lth,width);     
        end
end
%save corresponding output
switch(structure_type)
    case('volume')
        hdr.vol = clstat;
        save_nifti(hdr,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_stat.nii'));
        if exist('pstat','var')
            hdr.vol = pstat;
            save_nifti(hdr,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_pval.nii'));
        end
        if exist('logpstat','var')
            hdr.vol = logpstat;
            save_nifti(hdr,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_log10pval.nii'));
        end
    case('surface')
        if save_gifti
            if size(clstat,2) > 1
                stat_cifti.cdata = clstat';
            else
                stat_cifti.cdata = clstat;
            end
            save(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_stat.func.gii'),'Base64Binary');
            if exist('pstat','var')
                if size(pstat,2) > 1
                    stat_cifti.cdata = pstat';
                else
                    stat_cifti.cdata = pstat;
                end
                save(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_pval.func.gii'),'Base64Binary');
            end
            if exist('logpstat','var')
                if size(logpstat,2) > 1
                    stat_cifti.cdata = logpstat';
                else
                    stat_cifti.cdata = logpstat;
                end
                save(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_logpval.func.gii'),'Base64Binary');                
            end
        else
            if size(clstat,2) > 1
                stat_cifti.cdata = clstat';
            else
                stat_cifti.cdata = clstat;
            end
            ciftisave(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_stat.dscalar.nii'),wb_command);
            if exist('pstat','var')
                if size(pstat,2) > 1
                    stat_cifti.cdata = pstat';
                else
                    stat_cifti.cdata = pstat;
                end
                ciftisave(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_pval.dscalar.nii'),wb_command);
            end
            if exist('logpstat','var')
                if size(logpstat,2) > 1
                    stat_cifti.cdata = logpstat';
                else
                    stat_cifti.cdata = logpstat;
                end
                ciftisave(stat_cifti,strcat(output_path,'/',output_prefix,'_',file_id,zstr,'_logpval.dscalar.nii'),wb_command);                
            end
        end
end
end


