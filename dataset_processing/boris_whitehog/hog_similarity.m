function [val] = hog_similarity(hog1, hog2, padsize)
% HOGSIM - Calculates the pairwise similarity between the HOG descriptors 
%
% Syntax:  [val] = hog_similarity(hog1, hog2, padsize)
%
% Inputs:
%    hog1, hog2 - HOG descriptors
%    padsize - size of zero padding around the image
%
% Outputs:
%    val  - max convolution score
%

val1 = zeros(numel(hog1), numel(hog2));

val2 = zeros(numel(hog1), numel(hog2));

parfor k = 1:numel(hog1)*numel(hog2)    
    
    [i,j] = ind2sub([numel(hog1) numel(hog2)], k);
               
    H1 = hog1(i).data;
    H2 = hog2(j).data;
    
    res = getHogSimilarity(H1, H2, padsize);
    val1(k) = res(1);
    val2(k) = res(2);
        
end

val = cat(3, val1, val2);
