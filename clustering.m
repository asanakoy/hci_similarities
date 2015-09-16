function [ output_args ] = clustering( category )
%CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

load(['simMatrix_', category, '.mat']);

pathtodata = ['../crops/',category,'/']
numberFurthestNeighbours = 4000;

simMatrixIdx = zeros (size(simMatrix));
for i = 1:size(simMatrix,1)
    [~,simMatrixIdx(i,:)] = sort(simMatrix(i,:),'descend');
    
end


seq_names = image_names(:,3:25);
unq_seq_names = unique (seq_names,'rows');
for i = 1:size(unq_seq_names,1)
    seqIdx{i} = find(ismember(seq_names,unq_seq_names(i,:),'rows'));
    
end


nclusters = 10;
cliques = {};
weights = [];
flips = {};
for i= 1:nclusters
    
    
    %% Clique parameters
    maxNpoints = 20;
    k = 5;
    overlap_threshold = 0.005;
    
    %% Computer clique
    if length(cliques) < 1
        %First clique with random seed
        seed = round(1 + (size(simMatrix,1)-1).*rand(1,1));
        [clique, flipped,w] = findClique(simMatrixIdx, flipval, simMatrix, maxNpoints, seed, k, overlap_threshold ,seq_names, unq_seq_names,cliques);
        cliques{i} = clique;
        flips{i} = flipped;
        weights(i) = w/(length(clique)^2);
    else
        
        [clique, flipped, w] = findClique(simMatrixIdx, flipval,simMatrix, maxNpoints, seed, k, overlap_threshold ,seq_names, unq_seq_names,cliques);
        cliques{i} = clique;
        flips{i} = flipped;
        weights(i) = w/(length(clique)^2);
    end
    
    
    %% Compute medioid
    [~,maxIdx]=max(sum(simMatrix(clique,clique)));
    medioid = clique(maxIdx);
    
    %% Compute new seed
    maxCorr = zeros(size(simMatrix,1), length(cliques));
    meanCorr = zeros(size(simMatrix,1), length(cliques));
    for k = 1:size(simMatrix,1)
        
        for j = 1:length(cliques)
            maxCorr(k,j)=max(simMatrix(k,cliques{j}));
            meanCorr(k,j)=mean(simMatrix(k,cliques{j}));
            
        end
        
    end
    [~,perm]=sort(mean(maxCorr,2),'ascend');
    seed = perm(randperm(round(length(perm)*.1),1));
    
%     [~,perm]=sort(sum(meanCorr,2),'ascend');
%     seed = perm(randperm(round(length(perm)*.1),1));
    

    
    
end

for i = 1:length(cliques)
    visualize(i,cliques{i},flips{i},image_names, seq_names, pathtodata, weights(i));
end


end

function [clique, clique_flip, w] = findClique(simMatrix, flipped, W, maxNpoints, seed, k , overlap_threshold, seq_names, unq_seq_names,cliques)



seedSeq = seq_names(seed,:);
NNSet = seed;
clique = [];
clique_flip = [];
first = 1;
flipaux = 0;



while NNSet
    
    %NNSet = unique(NNSet);
    length(NNSet);
    maxNNPerSequence = ones(1,size(unq_seq_names,1))*1;
    current = NNSet(end);
    currentflip = flipaux(end);
    maxNNPerSequence(current) = 1;
    NNSet(end) = [];
    
    
    if length(clique) < maxNpoints
        
        %Get NNs of current point avoiding correlation of current with itself
        count = 2;
        NNs = [];
        while length(NNs) < k && count < size(simMatrix,1)
            % Construct the NNs of the current point constraining for
            % images of the same sequence
            assert(count<=size(simMatrix,1));
            idx = find(ismember(unq_seq_names, seq_names(simMatrix(current,count),:),'rows'));
            if maxNNPerSequence(idx) > 0
                NNs = [NNs simMatrix(current,count)];
                maxNNPerSequence(idx) = maxNNPerSequence(idx) -1 ;
            end
            count = count +1;
        end
        
        
        if isempty(clique)
            % We assume the NNs of the seed form a clique
            NNSet = [NNs(end:-1:1) NNSet];
            flipaux = [flipped(current,NNs(end:-1:1)) flipaux];
            
            clique = [current NNs];
            clique_flip = [currentflip flipped(current,NNs)];
            
            
            
        else
            
            if ismember(current,clique) || ismember(current,cell2mat(cliques))
                % If the current point is already in the clique we skip it
                % in all cases but in the first iteration
                if first
                    NNSet = [NNs(end:-1:1) NNSet];
                    flipaux = [flipped(current,NNs(end:-1:1)) flipaux];
                    first = 0;
                end
                continue;
            end
%             if length(clique)>length(NNs)
%                 ov_thrs = overlap_threshold*(length(NNs)/length(clique));
%             else
%                 ov_thrs = overlap_threshold;
%             end
           ov_thrs = overlap_threshold;     
            
            
            if length(intersect(clique, NNs))/length([clique NNs]) >= ov_thrs 
                % If the intersection of the NNs of current point overlaps
                % with the clique more than a threshold we include the
                % point in the clique
                NNSet = [NNs(end:-1:1) NNSet];
                flipaux = [flipped(current,NNs(end:-1:1)) flipaux];
                clique = [clique current];
                clique_flip = [clique_flip currentflip];
                
            end
        end
        
    else
        % If thge clique has grown to the limit we stop
        break;
    end
    
    
end

w = sum(sum(W(clique,clique)));



end

function bool = mutuallyDistant(row, mat, measure)

maxCorr = max(row);
if strcmp(measure,'min')
    
    bool = maxCorr > min(min(mat));
    
elseif strcmp(measure, 'avg')
    
    [~, medioid] = max(sum(mat));
    bool = maxCorr > mean(mat(medioid,:));
    
end


end

function visualize(nclique,clique,flip,image_names, seq_names, pathtodata, w)

for i = 1:length(clique)
    
    
    name_frame = image_names(clique(i),3:end);
    fparts = strsplit(name_frame,'/');
    name_frame = [fparts{1},'/',sprintf('I%05d.png',str2num(fparts{2}(2:6))-1)];
    
    im=imresize(imread(fullfile(pathtodata,name_frame)),[200,200]);
    if flip(i) == 1
        disp('flipped')
        stack(:,:,:,i)=im(:,end:-1:1,:);
    else
        stack(:,:,:,i)=im;
        
    end
    
    
end
h = implay(stack);
set(h.Parent, 'Name', ['Clique ',num2str(nclique), ', with w=',num2str(w)]);

end