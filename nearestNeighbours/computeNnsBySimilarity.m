function [nns, similarities, isFlipped] = computeNnsBySimilarity(frameId, hogVectors, isQuiet)
% EXHAUSTIVE search of NNs

if nargin < 3 || isempty(isQuiet)
    isQuiet = 0;
end

tic;
similarities = zeros(length(hogVectors), 1, 'single');
isFlipped = zeros(length(hogVectors), 1, 'uint8');

hog = hogVectors{frameId};
inversedHog = hog(end:-1:1, end:-1:1, end:-1:1);

if ~isQuiet
    fprintf('Iteration:         ');
end
for i = 1:length(hogVectors)
    if (i == frameId)
        similarities(i) = realmax;
        continue;
    end
    if (~isQuiet && mod(i, 100) == 0)
        fprintf('\b\b\b\b\b\b\b%7d', i);
    end
   
    
    sim =  getHogSimilarity(hog, hogVectors{i}, 1, inversedHog);
    
    isFlipped(i) = (sim(2) > sim(1));
    similarities(i) = max(sim);

end

[similarities, nns] = sort(similarities, 'descend');
nns = uint32(nns);
isFlipped = isFlipped(nns);

% remove self frame
similarities(1) = [];
nns(1) = [];
isFlipped(1) = [];

if ~isQuiet
    fprintf('\n');
    toc
end

end
