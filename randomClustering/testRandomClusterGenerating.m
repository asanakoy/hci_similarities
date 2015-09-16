function [] = testRandomClusterGenerating()
%create random clustering

load simMatrix_basketball_layup.mat;
PATH_TO_DATA = '/net/hciserver03/storage/mbautist/Desktop/mbautista/Exemplar_CNN/crops/basketball_layup/';
imagesSeqNames = image_names(:,3:25);
seqNames = unique (imagesSeqNames,'rows');
nSequences = size(seqNames, 1);
frameSeqId = zeros(size(imagesSeqNames,1), 1); % frameSeqId(i) - id of the sequence  frame {i} belongs to
for i = 1:size(imagesSeqNames,1)
    frameSeqId(i,1) = find(ismember(seqNames, imagesSeqNames(i,:), 'rows'));
end

framesBySequences = cell(nSequences, 1); % seqFrames{i} = set of indices of frames that belong to i-th sequence
for i = 1:nSequences
    framesBySequences{i} = find(ismember(imagesSeqNames, seqNames(i,:), 'rows'))';
end


nFrames = size(simMatrix, 1);
nMaxPointsPerCluster = 50;
nIterations = 10000;
LOWER_BOUND_N_POINTS_PER_CLUSTER = 10;
UPPER_BOUND_N_POINTS_PER_CLUSTER = 150;
MAX_POINTS_PER_SEED_SEQ = 2;
MAX_POINTS_PER_SEQ = 5;

[weights, normalizedWeights, clusterSizes] = run(simMatrix, nIterations, framesBySequences, ...
                                                   LOWER_BOUND_N_POINTS_PER_CLUSTER, UPPER_BOUND_N_POINTS_PER_CLUSTER, ...
                                                   MAX_POINTS_PER_SEED_SEQ, MAX_POINTS_PER_SEQ);
avgWeight = sum(weights) / nIterations;
fprintf('average cluster weight: %f\n', avgWeight);
figure;
histfit(weights); title('weight');

avgNormalizedWeight = sum(normalizedWeights) / nIterations;
fprintf('average cluster normalized weight: %f\n', avgNormalizedWeight);
figure;
histfit(normalizedWeights); title('avg normalized weight');

avgClusterSize = sum(clusterSizes) / nIterations;
fprintf('average cluster size: %f\n', avgClusterSize);
figure;
histfit(clusterSizes); title('cluster size');

end

function [weights, normalizedWeights, clusterSizes] = run(simMatrix, nIterations, ...
                                                 framesBySequences, lbnPoints, ubnPoints,...
                                                 maxPointsPerSeedSeq, maxPointsPerSeq)
    
    weights = zeros(nIterations, 1);
    normalizedWeights = zeros(nIterations, 1);
    clusterSizes = zeros(nIterations, 1);
    fprintf('Iteration:     ');
    for i = 1:nIterations
        pointsPerCluster = lbnPoints + floor(rand * (ubnPoints - lbnPoints + 1));
        [cluster, ~]  = generateRandomCluster(framesBySequences, pointsPerCluster, maxPointsPerSeedSeq, maxPointsPerSeq);
        weights(i) = computeClusterWeight(simMatrix, cluster);
        normalizedWeights(i) = weights(i) / size(cluster, 2)^2;
        clusterSizes(i) = size(cluster, 2);
        if (mod(i, 1000) == 0)
            fprintf('\b\b\b\b\b\b\b%7d', i); 
        end
    end
    fprintf('\n'); 
end