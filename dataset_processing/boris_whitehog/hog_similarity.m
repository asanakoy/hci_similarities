function [val, I, J] = hog_similarity(hog1, hog2, padsize)
% HOGSIM - Calculates the similarity between the HOG descriptors 
%
% Syntax:  [val, flip, I, J] = hog_similarity(hog1, hog2, padsize)
%
% Inputs:
%    hog1, hog2 - HOG descriptors
%    convsize - scope of the convolution 
%
% Outputs:
%    val  - max convolution score
%    I, J - location of the maximum
%

val1 = zeros(numel(hog1), numel(hog2));
I1 = zeros(numel(hog1), numel(hog2));
J1 = zeros(numel(hog1), numel(hog2));

val2 = zeros(numel(hog1), numel(hog2));
I2 = zeros(numel(hog1), numel(hog2));
J2 = zeros(numel(hog1), numel(hog2));

parfor k = 1:numel(hog1)*numel(hog2)    
    
    [i,j] = ind2sub([numel(hog1) numel(hog2)], k);
               
    H1 = hog1(i).data;
    H2 = hog2(j).data;
    
    H2p = zeros(size(H1) + [2*padsize,2*padsize,0]);
    
    M = min(size(H2,1), size(H2p,1));
    N = min(size(H2,2), size(H2p,2));
    
    H2p(floor((size(H2p,1)-M)/2)+[1:M], floor((size(H2p,2)-N)/2)+[1:N],:) = ...
        H2(floor((size(H2,1)-M)/2)+[1:M], floor((size(H2,2)-N)/2)+[1:N],:);
    
    % compute the convolution
    C = convn(H2p, H1(end:-1:1,end:-1:1,end:-1:1), 'valid');
    
    val1(k) = max(C(:));
    [I1(k), J1(k)] = find(C==max(C(:)), 1);
     
    % everything the same, now with the flipped descriptor
    H2 = H2(:,end:-1:1,:);
    
    H2p(floor((size(H2p,1)-M)/2)+[1:M], floor((size(H2p,2)-N)/2)+[1:N],:) = ...
        H2(floor((size(H2,1)-M)/2)+[1:M], floor((size(H2,2)-N)/2)+[1:N],:);
    
    C = convn(H2p, H1(end:-1:1,end:-1:1,end:-1:1), 'valid');
    
    val2(k) = max(C(:));
    [I2(k), J2(k)] = find(C==max(C(:)), 1);
        
end

val = cat(3, val1, val2);
I = cat(3, I1, I2);
J = cat(3, J1, J2);


