function [stat_vector,nrois] = ConnMatrixtoConnVector(stat_map)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    nrois = length(stat_map);
    stat_vector = zeros(nrois*(nrois-1)/2,1);
    place_count = 1;
    for curr_roi = 1:nrois
        temp_stat_vec = stat_map(curr_roi,curr_roi+1:end);
        stat_vector(place_count:place_count-1+length(temp_stat_vec)) = temp_stat_vec;
        place_count = place_count + length(temp_stat_vec);
    end
end
