function [ otherNns, otherDistances, otherIsFlipped ] = computeOtherCategoryNnsExhaustively( iFrameId, hogVectors )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

load '/net/hciserver03/storage/asanakoy/workspace/similarities/nearestNeighbours/data/dataInfo_all.mat';

[nns, distances, isFlipped] = computeNnsExhaustively(iFrameId, hogVectors);
    
[ ~, ~, otherNns, otherDistances, otherIsFlipped ] =...
filterNeighbours( iFrameId, nns, distances, isFlipped, categoryLookupTable );

end

