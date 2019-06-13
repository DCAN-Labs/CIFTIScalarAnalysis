function [ stat_map ] = ConnVectortoConnMatrix(stat_vector,nrois)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
stat_map = NaN(nrois,nrois);
place_count = 1;
for curr_roi = 1:nrois-1
    temp_stat_row = stat_vector(place_count:place_count-1+nrois-curr_roi);
    stat_map(curr_roi,curr_roi+1:end) = temp_stat_row;
    stat_map(curr_roi+1:end,curr_roi) = temp_stat_row;
    place_count = place_count+nrois-curr_roi;
end

