function [] = computeAverageNN(model, category, frameID)
%COMPUTEAVERAGENN Summary of this function goes here
%   Detailed explanation goes here

% 
% load(['/export/home/asanakoy/workspace/OlympicSports/dataset_labeling/merged_data_last/labels_',category,'.mat'])
% frameID = labels(frameID).anchor

if strcmp(model, 'hoglda')
    path_sim = ['/export/home/mbautist/Desktop/projects/cnn_similarities/datasets/OlympicSports/similarities_lda/simMatrix_',category,'.mat'];
elseif strcmp(model, 'imagenet')
    path_sim = ['/export/home/mbautist/Desktop/projects/cnn_similarities/compute_similarities/sim_matrices/imagenet/simMatrix_',category,'_imagenet-alexnet_iter_0_fc7.mat'];
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
[simMatrix, flipval] = max(cat(3, simMatrix, simMatrix_flipped), [], 3);
flipval = uint8(flipval - 1);


path_images = ['~/workspace/OlympicSports/crops/',category,'/'];
imsize = 227;
nnns = 20;
images = zeros(imsize, imsize, 3, nnns, 'uint8');
weights = zeros(nnns, 1);

load(['~/workspace/OlympicSports/sim/simMatrix_',category,'.mat'], 'image_names', 'seq_names');


% seq_names = image_names(:,3:25);
image_names = cellfun(@(z) z(3:end), image_names, 'UniformOutput', false);

% frames_same_seq = find(ismember(seq_names, seq_names{frameID}, 'rows'));
anchor_seq = image_names{frameID}(1:23);
frames_same_seq = find(cellfun(@(z) strncmpi(z, anchor_seq, length(anchor_seq)), image_names));

idxs = setdiff(1:size(simMatrix, 1), frames_same_seq);
sims = simMatrix(frameID, idxs);
flips = flipval(frameID, idxs);

[~, NNs] = sort(sims, 'descend');

blending_image = zeros(imsize, imsize, 3, 'double');
w_sum = 0.0;
for i = 1:length(NNs(1:nnns))
    fparts = strsplit(image_names{NNs(i)},'/');
    imname = [fparts{1},'/',sprintf('I%05d.png', str2num(fparts{2}(2:6))-1)];
    image_path = fullfile(path_images,imname);
    im = imresize(imread(image_path),[imsize, imsize]);
    images(:, :, :, i) = im;
    
    im = im2double(im);
    if flips(NNs(i))
        im = fliplr(im);
    end
%     w = -1.0 / 100 * (i - 1) + 1;
    w = 1.0 / i;
    
    weights(i) = w;
    
    w_sum = w_sum + w;
    im_weighted = im * w;
    blending_image = blending_image + im_weighted;
end

% matched_images = blending.match_images(images);
% blending_image_matched = zeros(imsize, imsize, 3, 'double');
% for i = 1:length(weights)
%     blending_image_matched = blending_image_matched + im2double(matched_images(:, :, :, i)) * weights(i);
% end
% blending_image_matched = blending_image_matched / w_sum;

blending_image = blending_image / w_sum;




anchor_path = fullfile(path_images, image_names{frameID});
anchor_image = im2double(imresize(imread(anchor_path),[imsize, imsize]));

figure
subplot(1,3,1); imshow(anchor_image); title(['Anchor ', num2str(frameID)]);
subplot(1,3,2); imshow(blending_image); title(['Blending of ',num2str(nnns),' NNs. ', model]);
% subplot(1,3,3); imshow(blending_image_matched); title('Matched');

diff_mat = rgb2gray(anchor_image) - rgb2gray(blending_image);
score = norm(double(diff_mat),'fro');
fprintf('RGB dist for model %s is %d \n',model,score);

% diff_mat = rgb2gray(anchor_image) - rgb2gray(blending_image_matched);
% score = norm(double(diff_mat),'fro');
% fprintf('Matched:RGB dist for model %s is %d \n',model,score);

% imwrite(anchor_image, sprintf('~/tmp/blending/anchor%03d.png', ridx));
% imwrite(blending_image, sprintf('~/tmp/blending/anchor%03d_%s.png', ridx, model));
end

