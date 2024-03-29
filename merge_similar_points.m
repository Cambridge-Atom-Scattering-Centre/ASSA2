function [uniqX, varargout] = merge_similar_points(vecX,varargin)
% merge_similar_points will find similar values in vecX, within
% tollerance of 1E-12 (can be changed, TODO). It will then
% average the data points at these indcies for each vector in
% varargin.
varargout = varargin;
[uniqX,indxOfUniqVal,indxOfSimVal]=uniquetol(vecX,1e-12);
for i=1:length(varargout)
    vecY = varargout{i};
    for j=1:length(uniqX)
        ind = find(j == indxOfSimVal);
        if length(ind) < 1, continue; end
        vecY(ind) = mean(vecY(ind));
    end
    varargout{i} = vecY(indxOfUniqVal);
end

end