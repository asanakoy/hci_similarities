function [weight] = computeClusterWeight(simMatrix, cluster)
%Compute sum of the Weights of all the cluster's pairwise edges
    weight = 0.0;
    for i = 1:size(cluster, 2)
        for j = (i + 1):size(cluster, 2)
            weight = weight + simMatrix(cluster(1, i), cluster(1, j));
        end
    end
end