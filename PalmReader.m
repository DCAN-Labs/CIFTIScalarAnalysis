function [design_mat,contrast_mat,ftest_mat,sub_mat] = PalmReader(ncases,varargin)
%PalmReader is a MATLAB interface for producing designs to run in fsl PALM.
%After it is run, one can execute palm using the output files. Please be
%sure to specify an output using the 'SaveOutput' parameter. More details
%below.
%%%%%%%% INPUTS %%%%%%
% ncases -- the number of cases (i.e. participants) that will be run
% using PALM. 
%Options below are specified by typing the parameter in single
%quotes followed by the input itself (see usage below):
% *'AnalysisType'* -- The type of analysis to conduct. If not selected 
% the program will quit. Currently, there are four possible selections:
%
%                   1) 'one_sample_test' -- use this when comparing a
%                   single group against zero -- useful for 
%                   analyses on high-level statistics (e.g. paired t-tests).
%                   2) 'two_sample_test' -- a comparison of means between
%                   two groups. Make sure to specify the group assignments
%                   using the 'Groups' parameter.
%                   3) 'anova' -- a between subjects ANOVA only. Uses a GLM
%                   to estimate mixed effects from the GLM, which
%                   simplifies mathematically to an analysis of variance.
%                   Consult with the fsl documentation for the proof. Make
%                   sure that the 'Groups' parameter is set to include the
%                   right number of factors with the right number of
%                   levels. Will also need to specify 'NumFactors', and
%                   'LevelsPerFactor'
%                   4) 'rmanova' -- a mixed effects GLM that assumes the
%                   covariance between all repeated measures is roughly
%                   equal. The parameter 'NumRepeatedMeasures' must be specified. 
%                   One can specify a combined analysis by including the 
%                   following three parameters: 'Groups','NumFactors',
%                   'LevelsPerFactor'. Otherwise, this will be a fully 
%                   within subject design.
%
% *'NumFactors'* -- an required scalar for between subject and combined ANOVAs
%  specifies the number of between subject factors.
% *'LevelsPerFactor'* -- a required M by 1 vector for between subject and 
%  combined ANOVAs, where M is the number of between subject factors. Each 
%  number specifies the number of levels per factor (e.g. three groups 
%  would be three levels).
% *'NumRepeatedMeasures'* -- a required scalar for within subject repeated
%  measures. Specifies the number of repeated measures per subject. All
%  subjects must have all repeated measures.
% *'Groups'* -- a N by M vector where N is the number of cases, and M is the
%  number of between subject factors. Lists the assignment of each case to
%  each factor. Required for between subject and combined ANOVAs. If the
%  number of unique values does not equal the specified factor level, an
%  error will occur.
% *'SaveOutput'* -- a string that represents the full path to the output
% directory. The program will save the design files in that directory.
% *'RegressorVector'* -- a vector denoting which columns in Groups are
% actually continuous variables. Only used if "regression" is selected. If
% left unspecified, all columns in groups are assumed to be regressors.
% Regressors will be automatically mean-centered, in case one forgot to do
% so.
%%%%%%%% OUTPUTS %%%%%
% design_mat -- a N*RM by EV  matrix where N is the number of cases, RM is 
%  the number of repeated measures and EV is the number of parameter 
%  estimates in the GLM. PalmReader determines the neccessary number of 
%  parameters from the inputs specified above. This is equivalent to the 
%  design.mat FSL file.
% contrast_mat -- a C by EV matrix, where C is the number of specified
%  contrasts and EV is the number of parameters estimated by the GLM. 
%  Each contrast comprises a vector of relative linear weights for the parameter estimates. 
%  The contrasts are used in the ANOVA analysis in combination in order to test
%  specific factors and interactions. This is equivalent to the design.con
%  FSL file.
% ftest_mat -- a F by C matrix, where F is the number of statistical ANOVA
%  tests and C is the number of specified contrasts. This is equivalent to
%  the design.fsf FSL file.
% sub_mat -- a N*RM by 1 matrix, where N is the number of cases, and RM is 
% the number of repeated measures. This is used by PALM to ensure proper
% permutation testing. This is equivalent to the design.grp FSL file.
%%%%%%%% USAGE %%%%%%%
% [design_mat,contrast_mat,ftest_mat,sub_mat] = PalmReader(ncases=20,'AnalysisType',analysis_type='anova','SaveOutput',output_directory='/path/to/output/','Groups',group_factors = [ 1 1 0 0...;0 0 2 1...],'NumFactors',numfactors=2,'LevelsPerFactor',factor_levels = [2 2])
save_output = 0;
two_tailed = false;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            if ischar(varargin{i}) == 1 || max(size(varargin{i})) == 1
                switch(varargin{i})
                    case('AnalysisType')
                        analysis_type = varargin{i+1};
                    case('NumFactors')
                        numfactors = varargin{i+1};
                    case('LevelsPerFactor')
                        factor_levels = varargin{i+1};
                    case('NumRepeatedMeasures')
                        numrm = varargin{i+1};
                    case('SaveOutput')
                        save_output = 1;
                        output_directory = varargin{i+1};
                    case('Groups')
                        groupfactors = varargin{i+1};
                    case('RegressorVector')
                        regressors = varargin{i+1};
                end
            end
        end
    end
end
try
    isempty(analysis_type);
catch
    msg = 'Analysis type is undefined. Please make sure to select an analysis type using the parameter input "AnalysisType"';
    error(msg)
end
switch(analysis_type)
    case('one_sample_test')
        design_mat = ones(ncases,1);
        contrast_mat = 1;
        two_tailed=true;
    case('two_sample_test')
        design_mat = [ones(ncases,1).*groupfactors 1-ones(ncases,1).*groupfactors];
        contrast_mat = [1 -1; -1 1];
    case('regression')
        if exist('regressors','var')
        else
            regressors = ones(size(groupfactors,2),1);
        end
        for curr_groupfactor = 1:size(groupfactors,2)
            if regressors(curr_groupfactor) > 0
                groupfactors(:,curr_groupfactor) = groupfactors(:,curr_groupfactor) - mean(groupfactors(:,curr_groupfactor));
            end
        end
        design_mat = groupfactors(:,regressors > 0);
        contrast_mat = eye(size(design_mat,2),size(design_mat,2));
        two_tailed = true;
    case('anova')
        evcount = 0;
        evcountthresh = [ 0 cumsum(factor_levels -1)];
        if factor_levels(1) < 3
            evcount = evcount + 1;
            ev(:,evcount) = groupfactors(:,1);
            ev(groupfactors(:,1) == 0,evcount) = -1;
        else
            for levelnum = 1:factor_levels(1)-1
                evcount = evcount + 1;
                ev(:,evcount) = double(groupfactors(:,1) == levelnum);
                ev(groupfactors(:,1) == 0,evcount) = -1;
            end
        end
        for iter = 2:numfactors
            if factor_levels(iter) < 3
                evcount = evcount + 1;
                ev(:,evcount) = groupfactors(:,iter);
                ev(groupfactors(:,iter) == 0,evcount) = -1;                
            else
                for levelnum = 1:factor_levels(iter)-1
                    evcount = evcount + 1;
                    ev(:,evcount) = double(groupfactors(:,iter) == levelnum);
                    ev(groupfactors(:,iter) == 0,evcount) = -1;
                end
            end
        end
        for iter = 1:numfactors - 1
            for seconditer = iter+1:numfactors            
                for factoriter = 1:(factor_levels(iter)-1)
                    for factorseconditer = 1:(factor_levels(seconditer)-1)
                        evcount = evcount + 1;
                        ev(:,evcount) = ev(:,evcountthresh(iter)+factoriter).*ev(:,evcountthresh(seconditer)+factorseconditer);
                    end
                end
            end
        end
        if numfactors > 2
            for iter = 1:numfactors - 2
                for seconditer = iter+1:numfactors -1
                    for thirditer = seconditer+1:numfactors                    
                        for factoriter = 1:(factor_levels(iter)-1)
                            for factorseconditer = 1:(factor_levels(seconditer)-1)
                                for factorthirditer = 1:(factor_levels(thirditer)-1)
                                    evcount = evcount + 1;
                                    ev(:,evcount) = ev(:,evcountthresh(iter)+factoriter).*ev(:,evcountthresh(seconditer)+factorseconditer).*ev(:,evcountthresh(thirditer)+factorthirditer);
                                end
                            end
                        end
                    end
                end
            end
        end
        if numfactors > 3
            for iter = 1:numfactors - 3
                for seconditer = iter+1:numfactors -2              
                    for thirditer = seconditer+1:numfactors-1       
                        for fourthiter = thirditer+1:numfactors                                
                            for factoriter = 1:(factor_levels(iter)-1)
                                for factorseconditer = 1:(factor_levels(seconditer)-1)
                                    for factorthirditer = 1:(factor_levels(thirditer)-1)
                                        for factorfourthiter = 1:(factor_levels(fourthiter)-1)
                                            evcount = evcount + 1;
                                            ev(:,evcount) = ev(:,evcountthresh(iter)+factoriter).*ev(:,evcountthresh(seconditer)+factorseconditer).*ev(:,evcountthresh(thirditer)+factorthirditer).*ev(:,evcountthresh(fourthiter)+factorfourthiter);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if numfactors > 4
            for iter = 1:numfactors - 4
                for seconditer = iter+1:numfactors -3  
                    for thirditer = seconditer+1:numfactors-2
                        for fourthiter = thirditer+1:numfactors-1   
                            for fifthiter = fourthiter+1:numfactors                            
                                for factoriter = 1:(factor_levels(iter)-1)
                                    for factorseconditer = 1:(factor_levels(seconditer)-1)
                                        for factorthirditer = 1:(factor_levels(thirditer)-1)
                                            for factorfourthiter = 1:(factor_levels(fourthiter)-1)
                                                for factorfifthiter = 1:(factor_levels(fifthiter)-1)
                                                    evcount = evcount + 1;
                                                    ev(:,evcount) = ev(:,evcountthresh(iter)+factoriter).*ev(:,evcountthresh(seconditer)+factorseconditer).*ev(:,evcountthresh(thirditer)+factorthirditer).*ev(:,evcountthresh(fourthiter)+factorfourthiter).*ev(:,evcountthresh(fifthiter)+factorfifthiter);
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if numfactors > 5
            for iter = 1:numfactors - 5
                for seconditer = iter+1:numfactors - 4       
                    for thirditer = seconditer+1:numfactors- 3     
                        for fourthiter = thirditer+1:numfactors- 2  
                            for fifthiter = fourthiter+1:numfactors-1
                                for sixthiter = fifthiter+1:numfactors                                                                                       
                                    for factoriter = 1:(factor_levels(iter)-1)
                                        for factorseconditer = 1:(factor_levels(seconditer)-1)
                                            for factorthirditer = 1:(factor_levels(thirditer)-1)
                                                for factorfourthiter = 1:(factor_levels(fourthiter)-1)
                                                    for factorfifthiter = 1:(factor_levels(fifthiter)-1)
                                                        for factorsixthiter = 1:(factor_levels(sixthiter)-1)
                                                            evcount = evcount + 1;
                                                            ev(:,evcount) = ev(:,evcountthresh(iter)+factoriter).*ev(:,evcountthresh(seconditer)+factorseconditer).*ev(:,evcountthresh(thirditer)+factorthirditer).*ev(:,evcountthresh(fourthiter)+factorfourthiter).*ev(:,evcountthresh(fifthiter)+factorfifthiter).*ev(:,evcountthresh(sixthiter)+factorsixthiter);
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end        
        design_mat = [ ev ones(ncases,1) ];
        contrast_mat = [eye(size(ev,2)) zeros(size(ev,2),1)];
        nftests = 0;
        for currfactor = 1:numfactors
            nftests = nftests + nchoosek(numfactors,currfactor);
        end
        ftest_mat = zeros(nftests,size(contrast_mat,1));
        ftest_count = 0;
        evcount = 0;
        for currfactor = 1:numfactors
            ftest_count = ftest_count + 1;
            for currlevel = 1:factor_levels(currfactor) -1
                evcount = evcount + 1;
                ftest_mat(ftest_count,evcount) = 1;
            end
        end
        for factorone = 1:numfactors - 1
            for factortwo = factorone+1:numfactors
                ftest_count = ftest_count + 1;
                for currfactorone = 1:factor_levels(factorone) - 1
                    for currfactortwo = 1:factor_levels(factortwo) - 1
                       evcount = evcount + 1;
                       ftest_mat(ftest_count,evcount) = 1;
                    end
                end
            end
        end
        if numfactors > 2
            for factorone = 1:numfactors - 2
                for factortwo = factorone+1:numfactors - 1
                    for factorthree = factortwo+1:numfactors
                        ftest_count = ftest_count + 1;
                        for currfactorone = 1:factor_levels(factorone) - 1
                            for currfactortwo = 1:factor_levels(factortwo) - 1
                                for currfactorthree = 1:factor_levels(factorthree) - 1
                                    evcount = evcount + 1;
                                    ftest_mat(ftest_count,evcount) = 1
                                end
                            end
                        end
                    end
                end
            end            
        end
        if numfactors > 3
            for factorone = 1:numfactors - 3
                for factortwo = factorone+1:numfactors - 2
                    for factorthree = factortwo+1:numfactors - 1
                        for factorfour = factorthree+1:numfactors
                            ftest_count = ftest_count + 1;
                            for currfactorone = 1:factor_levels(factorone) - 1
                                for currfactortwo = 1:factor_levels(factortwo) - 1
                                    for currfactorthree = 1:factor_levels(factorthree) - 1
                                        for currfactorfour = 1:factor_levels(factorfour) - 1
                                            evcount = evcount + 1;
                                            ftest_mat(ftest_count,evcount) = 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end               
        end
        if numfactors > 4
            for factorone = 1:numfactors - 4
                for factortwo = factorone+1:numfactors - 3
                    for factorthree = factortwo+1:numfactors - 2
                        for factorfour = factorthree+1:numfactors -1
                            for factorfive = factorfour+1:numfactors
                                ftest_count = ftest_count + 1;
                                for currfactorone = 1:factor_levels(factorone) - 1
                                    for currfactortwo = 1:factor_levels(factortwo) - 1
                                        for currfactorthree = 1:factor_levels(factorthree) - 1
                                            for currfactorfour = 1:factor_levels(factorfour) - 1
                                                for currfactorfive = 1:factor_levels(factorfive) - 1
                                                    evcount = evcount + 1;
                                                    ftest_mat(ftest_count,evcount) = 1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end            
        end
        if numfactors > 5
            for factorone = 1:numfactors - 5
                for factortwo = factorone+1:numfactors - 4
                    for factorthree = factortwo+1:numfactors - 3
                        for factorfour = factorthree+1:numfactors - 2
                            for factorfive = factorfour+1:numfactors - 1
                                for factorsix = factorfive+1:numfactors
                                    ftest_count = ftest_count + 1;
                                    for currfactorone = 1:factor_levels(factorone) - 1
                                        for currfactortwo = 1:factor_levels(factortwo) - 1
                                            for currfactorthree = 1:factor_levels(factorthree) - 1
                                                for currfactorfour = 1:factor_levels(factorfour) - 1
                                                    for currfactorfive = 1:factor_levels(factorfive) - 1
                                                        for currfactorsix = 1:factor_levels(factorsix) - 1
                                                            evcount = evcount + 1;
                                                            ftest_mat(ftest_count,evcount) = 1;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end                
        end                
    case('rmanova')
        if exist('numfactors','var') == 0
            sub_mat = ones(ncases*numrm,1);
            nevs = numrm-1 + ncases;
            ev = zeros(ncases*numrm,nevs);
            curr_ev = 0;
            ev(1:numrm:ncases*numrm,1:numrm) = 1;
            for currmeas = 2:numrm
                curr_ev = curr_ev + 1;
                ev(currmeas:numrm:ncases*numrm,curr_ev) = -1;
                sub_mat(currmeas:numrm:end) = currmeas;
            end
            for currsubj = 1:ncases
                curr_ev = curr_ev + 1;
                ev(1 + (currsubj-1)*numrm:currsubj*numrm,curr_ev) = 1;
            end
            ncontrasts = 0;
            for iter = 1:numrm-1
                ncontrasts = ncontrasts + numrm-iter;
            end
            ncontrasts = ncontrasts*2;
            contrast_mat = zeros(ncontrasts,nevs);
            curr_contrast = 0;
            for measone = 1:numrm - 1
                for meastwo = measone+1:numrm
                    curr_contrast = curr_contrast + 1;
                    contrast_mat(curr_contrast,:) = sum(ev(measone:numrm:end,:)) - sum(ev(meastwo:numrm:end,:));
                end
            end
            ftest_mat = eye(ncontrasts);
            design_mat = ev;
        else
        end
end
if save_output
    mkdir(output_directory);
    dlmwrite(strcat(output_directory,'/design_matrix.txt'),design_mat,'delimiter','\t');
    dlmwrite(strcat(output_directory,'/contrast_matrix.txt'),contrast_mat,'delimiter','\t');  
    if exist('ftest_mat','var')
        dlmwrite(strcat(output_directory,'/ftest_matrix.txt'),ftest_mat,'delimiter','\t'); 
    end
    if exist('sub_mat','var')
        dlmwrite(strcat(output_directory,'/rm_matrix.txt'),sub_mat,'delimiter','\t'); 
    end
end
end

