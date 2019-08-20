function [eta_matrix] = CalcEtaSquaredMats(mata,matb)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1
    mat_sim = zeros(size(mata,1)*(size(mata,1)-1)/2,2);
    mat_sim(:,1) = mata(abs(triu(mata,1)) > 0);
    mat_sim(:,2) = matb(abs(triu(matb,1)) > 0);
else
    mat_sim = zeros(size(mata,1)*(size(mata,1)-1)/2,size(mata,3));
    for curr_mat = 1:size(mata,3)
        curr_mat
        temp_mat = mata(:,:,curr_mat);
        mat_sim(:,curr_mat) = temp_mat(abs(triu(temp_mat,1))>0);
    end
end
nmat = size(mat_sim,2);
eta_matrix=ones(nmat);
for i=1:nmat-1
    for j=i+1:nmat
        % mean correlation value over all locations in both images
        Mgrand = (mean(mat_sim(:,i)) + mean(mat_sim(:,j)))/2;
        % mean value matrix for each location in the 2 images
        Mwithin = (mat_sim(:,i)+mat_sim(:,j))/2;
        SSwithin = sum((mat_sim(:,i)-Mwithin).^2) + sum((mat_sim(:,j)-Mwithin).^2);
        SStot = sum((mat_sim(:,i)-Mgrand).^2) + sum((mat_sim(:,j)-Mgrand).^2);
        % N.B. SStot = SSwithin + SSbetween so eta can also be written as SSbetween/SStot
        eta_matrix(i,j) = 1- SSwithin/SStot;
        eta_matrix(j,i) = eta_matrix (i,j);
    end
end

end

