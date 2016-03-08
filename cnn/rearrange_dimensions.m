function [] = rearrange_dimensions()
%REARRANGE_DIMENSIONS 
% For each category: 1. Load 3D features. 
%                    2. Rearrange dimensions of each single feature
%                    3. Save features to file in single precision.

addpath(genpath(Config.SELF_ROOT));
dataset_path = '~/workspace/OlympicSports';
features_input_path = '/net/hciserver03/storage/mbautist/Desktop/projects/cnn_similarities/data/writeDB/';
output_path = '~/workspace/OlympicSports/alexnet/features/';

data_info = load(DatasetStructure.getDataInfoPath(dataset_path), 'categoryNames');

features = [];
features_flip = [];
for i = 1:length(data_info.categoryNames)
    fprintf('Reading and rearranging the dimensions of features for %s...\n', data_info.categoryNames{i});
    
    filename = sprintf('features_%s_imagenet-alexnet_iter_0_conv5.mat', data_info.categoryNames{i});
    file = load(fullfile(features_input_path, filename));
    
    features      = single(permute(file.features, [1, 4, 3, 2]));
    features_flip = single(permute(file.features_flip, [1, 4, 3, 2]));
    
    fprintf('%s -> %s\n', mat2str(size(file.features)), mat2str(size(features)));
    
    assert(all(size(features) == size(features_flip)), ...
        'size %s != %s', mat2str(size(features)), size(features_flip));
    
    fprintf('Saving on disk...\n');
    file_to_save = fullfile(output_path, filename);
    save(file_to_save, '-v7.3', 'features', 'features_flip');  
end

end

