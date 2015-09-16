function [ cliques ] = randomClustering()
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
nIterations = 1000;
MAX_POINTS_PER_SEED_SEQ = 2;
MAX_POINTS_PER_SEQ = 3;

weights = testRandomClusterGenerating(simMatrix, nFrames, nIterations, nSequences,...
                                      framesBySequences, nMaxPointsPerCluster, MAX_POINTS_PER_SEED_SEQ, MAX_POINTS_PER_SEQ);
avgWeights = sum(weights) / nIterations;
fprintf('average cluster wight: %f\n', avgWeights);
histfit(weights);



% nClusters = 2;
% [clusters, weights] = generateIndependentRandomClusters(simMatrix, nFrames, nClusters, nSequences, framesBySequences, nMaxPointsPerCluster);
% 
% fprintf('generated %d clusters, max %d images each\n', size(clusters,1), nMaxPointsPerCluster);
% 
% for i = 1:size(clusters,1)
%     fprintf('cluster %d:  size=%d, weight=%f\n', i, size(clusters{i}, 2), weights(i));
%     visualize(PATH_TO_DATA, imagesSeqNames, image_names, clusters{i});
% end

end

%==========================================================================
function [clusters, weights] = generateIndependentRandomClusters(simMatrix, nFrames,...
                                        nClusters, nSequences, framesBySequences, nMaxPointsPerCluster)

    nPointsPerCluster = nMaxPointsPerCluster;
    if nFrames < nClusters * nPointsPerCluster
        nPointsPerCluster = nFrames / nClusters;
    end

    sequenceUsed = zeros(nSequences, 1);

    clusters = cell(nClusters, 1);

    weights = zeros(nClusters, 1);
    for i = 1:nClusters
        [clusters{i} framesBySequences]  = generateRandomCluster(framesBySequences, nMaxPointsPerCluster,...
                                                                 maxPointsPerSeedSeq, maxPointsPerSeq);
        weights(i) = computeClusterWeight(simMatrix, clusters{i});
    end

end



%==========================================================================
function visualize(pathsToImages, imagesSeqNames, imageNames, cluster)

    for i = 1:length(cluster)


        frameName = imageNames(cluster(i),3:end);
        fparts = strsplit(frameName,'/');
        frameName = [fparts{1},'/',sprintf('I%05d.png',str2num(fparts{2}(2:6))-1)];


        figure,imshow(fullfile(pathsToImages,frameName));
        title(imagesSeqNames(cluster(i),:),'Interpreter','none')
        pause

    end
end