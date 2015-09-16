function [cluster restFrames] = generateRandomCluster(framesBySequences, nMaxPoints, maxPointsPerSeedSeq, maxPointsPerSeq)
%Generate random cluster
    nSequences = size(framesBySequences,1);
    restFrames = framesBySequences(randperm(nSequences));

    cluster = [];
    iSeq = 1;
    while size(cluster, 2) < nMaxPoints && iSeq <= nSequences 
        currentSequeneSize = size(restFrames{iSeq},2);
        restFrames{iSeq} = restFrames{iSeq}(1, randperm(currentSequeneSize));
        if iSeq > 1
            nPointsToGenerate = ceil(rand * maxPointsPerSeq);
        else
            nPointsToGenerate = ceil(rand * maxPointsPerSeedSeq);
        end
        nPointsToGenerate = min([nPointsToGenerate currentSequeneSize (nMaxPoints - size(cluster, 2))]);
        cluster = [cluster restFrames{iSeq}(1:nPointsToGenerate)];
        restFrames{iSeq}(1:nPointsToGenerate) = []; % remove used points
        
        iSeq = iSeq + 1;
    end

end