function [nns, distances, isFlipped] = computeNnsExhaustively(frameId, hogVectors, maxHogSize)
% EXHAUSTIVE search of NNs

HOG_SIZE = maxHogSize;

tic;
distances = zeros(length(hogVectors), 1);
isFlipped = zeros(length(hogVectors), 1);

hog = hogVectors(:, frameId);
flippedHog = reshape(fliplr(reshape(hog, HOG_SIZE)), prod(HOG_SIZE), 1);

fprintf('Iteration:         ');
for i = 1:size(hogVectors, 2)
    if (i == frameId)
        distances(i) = realmax;
        continue;
    end
    if (mod(i, 100) == 0)
        fprintf('\b\b\b\b\b\b\b%7d', i);
    end
   
    delta = hog - hogVectors(:,i);
    dist = sum(delta .* delta);
    
    fippedDelta = flippedHog - hogVectors(:,i);
    flippedDist = sum(fippedDelta .* fippedDelta);
    
    isFlipped(i) = (flippedDist < dist);
    distances(i) = min([dist flippedDist]);

end

fprintf('sorting distances...');
[distances, nns] = sort(distances);
isFlipped = isFlipped(nns);

% remove self frame
distances(end) = [];
nns(end) = [];
isFlipped(end) = [];

fprintf('\n');
toc

end
