% catId = 16; % long_jump
% 
% indices = find(categoryLookupTable == catId);
% frameId = indices(ceil(rand * length(indices)));
frameId = 80010;
%frameId = ceil(rand * 105650);
% frameId = SNG.frameId{k};

fprintf('searched frame ID: %d\n', frameId);
figure;
title = sprintf('original id %d', frameId);
showImage(frameId, sequenceFilesPathes, sequenceLookupTable, title);

[ ~, ~, otherNns, otherDistances, otherIsFlipped ] = ...
                        computeOtherCategoryNns(frameId, hogVectors );

% SNG.dist{k} = otherDistances;
% SNG.nns{k} = otherNns;
% SNG.isFlipped{k} = otherIsFlipped;
% SNG.frameId{k} = frameId;
% k = k + 1;

% DBL.dist{k} = otherDistances;
% DBL.nns{k} = otherNns;
% DBL.isFlipped{k} = otherIsFlipped;
% DBL.frameId{k} = frameId;git add
% k = k + 1;
NNS_NUM_TO_SHOW = 40;
showNeighbours( otherNns(1:NNS_NUM_TO_SHOW), ...
                otherDistances(1:NNS_NUM_TO_SHOW), ...
                otherIsFlipped(1:NNS_NUM_TO_SHOW), ...
                sequenceFilesPathes, sequenceLookupTable );

% showNeighbours(nns(frameId,:), distances(frameId,:), isFlipped(frameId,:), sequenceFilesPathes, sequenceLookupTable);

