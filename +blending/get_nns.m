function [ nns, flips ] = get_nns(model, category, frameID, num_nns)
%COMPUTEAVERAGENN Summary of this function goes here
%   Detailed explanation goes here

if strcmp(model, 'hoglda')
    path_sim = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/hog-lda/simMatrix_',category,'.mat'];
elseif strcmp(model, 'imagenet')
    path_sim = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/imagenet/simMatrix_',category,'_imagenet-alexnet_iter_0_fc7.mat'];
elseif strcmp(model, 'ours')
    path_sim = ['/export/home/mbautist/Desktop/workspace/cnn_similarities/compute_similarities/sim_matrices/CliqueCNN/simMatrix_correct_',...
        category,'_cliqueCNN_',category,'_LR_0.001_M_0.9_BS_128_iter_20000_fc7_prerelu.mat'];
    
end

sim = load(path_sim);
simMatrix = sim.simMatrix;
if ~exist('simMatrix_flipped', 'var')
    simMatrix_flipped = sim.simMatrix_flip;
else
    simMatrix_flipped = sim.simMatrix_flipped;
end

simMatrix_flipped = simMatrix_flipped - diag(diag(simMatrix_flipped));
[simMatrix, flipvals] = max(cat(3, simMatrix, simMatrix_flipped), [], 3);
flipvals = uint8(flipvals - 1);


load(['~/workspace/OlympicSports/sim/simMatrix_',category,'.mat'], 'image_names', 'seq_names');


image_names = cellfun(@(z) z(3:end), image_names, 'UniformOutput', false);
anchor_seq = image_names{frameID}(1:23);
fprintf('anchor seq: %s\n', anchor_seq);
frames_same_seq = find(cellfun(@(z) strncmpi(z, anchor_seq, length(anchor_seq)), image_names));
% frames_same_seq = [frameID, max(1, frameID - 1), min(frameID + 1, length(simMatrix))];
% frames_same_seq = [frames_same_seq(:)', anchor_seq-200:anchor_seq+200];

% idxs = setdiff(1:size(simMatrix, 1), frames_same_seq);
sims = simMatrix(frameID, :);
sims(frames_same_seq) = 0;
[~, nns] = sort(sims, 'descend');

% flips = flipvals(frameID, idxs);
% flips = flips(nns);

max_per_seq = 2;
seq_count = zeros(length(seq_names));
k = 0;
it = 1;
res_nns = [];
res_flips = [];
while k < num_nns && it <= length(sims)
    cur_seq_name = image_names{nns(it)}(1:23);
    cur_seq_id = find(cellfun(@(z) strcmp(z, cur_seq_name), seq_names));
    if seq_count(cur_seq_id) < max_per_seq
        seq_count(cur_seq_id) = seq_count(cur_seq_id) + 1;
        k = k + 1;
        res_nns(end + 1) = nns(it);
        res_flips(end + 1) = flipvals(frameID, nns(it));
    end
    it = it + 1;
end

nns = res_nns;
flips = res_flips;
% nns = nns(1:num_nns);
% flips = flips(1:num_nns);

end