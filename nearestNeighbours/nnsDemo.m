% catId = 16; % long_jump
% 
% indices = find(categoryLookupTable == catId);
% frameId = indices(ceil(rand * length(indices)));
frameId = 80033;

fprintf('searched frame ID: %d\n', frameId);
figure;
title = sprintf('original id %d', frameId);
showImage(frameId, sequenceFilesPathes, sequenceLookupTable, title);

[ otherNns, otherDistances, isFlipped ] = computeOtherCategoryNnsExhaustively( frameId, hogVectors );

showNeighbours( otherNns(1:10), otherDistances(1:10), isFlipped(1:10), sequenceFilesPathes, sequenceLookupTable )