function y = check_null_distribution(x,null_distribution)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if isnan(x)
    y = 1;
else
   y = 1-find(null_distribution > x,1)/length(null_distribution);
   if isempty(y)
       y = 1/10000;
   end
end

end

