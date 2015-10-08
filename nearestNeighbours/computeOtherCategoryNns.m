function [ sameCatNns, sameCatDistances, otherNns, otherDistances, otherIsFlipped ] = computeOtherCategoryNns( iFrameId, hogVectors, categoryLookupTable )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



% [nns, distances, isFlipped] = computeNnsExhaustively(iFrameId, hogVectors, maxHogSize);
[nns, distances, isFlipped] = computeNnsBySimilarity(iFrameId, hogVectors);
    
[ sameCatNns, sameCatDistances, otherNns, otherDistances, otherIsFlipped ] =...
filterNeighbours( iFrameId, nns, distances, isFlipped, categoryLookupTable );

end

