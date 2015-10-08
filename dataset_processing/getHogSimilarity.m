function [val] = getHogSimilarity(H1, H2, padsize, H1_inversed)
% HOGSIM - Calculates the similarity between the HOG descriptors 
%
% Syntax:  [val] = hog_similarity(hog1, hog2, padsize)
%
% Inputs:
%    hog1, hog2 - HOG descriptors
%    convsize - scope of the convolution 
%
% Outputs:
%    val  - max convolution score
%

if nargin < 4 || isempty(H1_inversed)
    H1_inversed = H1(end:-1:1, end:-1:1, end:-1:1);
end

val1 = 0;
val2 = 0;

overlap_area = min(size(H1,1), size(H2,1)) * min(size(H1,2), size(H2,2));

H2p = zeros(size(H1) + [2 * padsize, 2 * padsize,0]);

M = min(size(H2,1), size(H2p,1));
N = min(size(H2,2), size(H2p,2));

H2p(floor((size(H2p, 1) - M) / 2) + [1:M], floor((size(H2p, 2) - N) / 2) + [1:N], :) = ...
  H2(floor((size(H2, 1) - M) / 2) + [1:M], floor((size(H2, 2) - N) / 2) + [1:N], :);

% compute the convolution
maxConvVal = convolve(H2p, H1_inversed);
val1 = maxConvVal / overlap_area;


% everything the same, now with the flipped descriptor
H2 = H2(:,end:-1:1,:);

H2p(floor((size(H2p, 1) - M) / 2) + [1:M], floor((size(H2p, 2) - N) / 2) + [1:N], :) = ...
  H2(floor((size(H2, 1) - M) / 2) + [1:M], floor((size(H2, 2) - N) / 2) + [1:N],:);

maxConvVal = convolve(H2p, H1_inversed);
val2 = maxConvVal / overlap_area;        

val = [val1, val2];

end

function [maxVal] = convolve(a, b)
    C = convn(a, b, 'valid');

    maxVal = max(C(:));
end

