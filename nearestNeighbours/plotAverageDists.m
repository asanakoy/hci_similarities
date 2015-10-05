function [ averageDistanses ] = plotAverageDists( hogVectors, numberOfTrials )
%Plot average distances to the neighbours

load '/net/hciserver03/storage/asanakoy/workspace/similarities/nearestNeighbours/data/dataInfo_all.mat';

if nargin < 2 || isempty(numberOfTrials)
   numberOfTrials = 100';
end

% frameIds = randperm(length(hogVectors), numberOfTrials);

frameIds = [80034];
numberOfTrials = length(frameIds);

trialNum = 1;
otherCatPoints = length(hogVectors) - 1;
averageDistanses = zeros(otherCatPoints,1);

for iFrameId = frameIds
    fprintf('Trial %d. ', trialNum);
    trialNum = trialNum + 1;
    [nns, distances] = computeNnsExhaustively(iFrameId, hogVectors);
    
    [ ~, sameCategoryDistances, ~, otherDistances ] =...
    filterNeighbours( iFrameId, nns, distances, categoryLookupTable );
    
    otherCatPoints = min([otherCatPoints length(otherDistances)]);
    averageDistanses = averageDistanses(1:otherCatPoints);
    averageDistanses = averageDistanses + otherDistances(1:otherCatPoints).^(1);

end

averageDistanses = averageDistanses / numberOfTrials;

fprintf('minimal otherCatPoints: %d\n', otherCatPoints);

figure;
plot(averageDistanses);
strTitle = sprintf('Average distances from other cat, %d trials', numberOfTrials);
title(strTitle);

figure;
plot(averageDistanses(1:100));
strTitle = sprintf('Average first 100 distances from other cat, %d trials', numberOfTrials);
title(strTitle);

end