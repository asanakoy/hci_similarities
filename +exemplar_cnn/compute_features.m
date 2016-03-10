function [] = compute_features(category_name, data_info, output_dir)
%COMPUTECNNFEATURES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/export/home/asanakoy/workspace/OlympicSports';

CAFFE_ROOT = getenv('CAFFE_ROOT');
HOME = '/export/home/asanakoy';%getenv('HOME');
if isempty(CAFFE_ROOT)
    error('CAFFE_ROOT environment variable is not set up!');
end
addpath(fullfile(CAFFE_ROOT, 'matlab'));

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

crops_path = fullfile(dataset_path, 'crops_96x96');

%load images
models = {'exemplar_cnn'};
model = models{1};

file_to_save = fullfile(output_dir, sprintf('features_%s_ecnn_fc5_36patches_quadrantpool_zscores.mat', category_name));
if exist(file_to_save, 'file')
    fprintf('Skip. File %s already exists!\n', file_to_save);
    return
end

% init network
params.model_def_file = [HOME '/workspace/similarities/+exemplar_cnn/deploy_',model,'.prototxt'];
params.model_file = sprintf([dataset_path '/exemplar_cnn/models/'...
                                  '64c5-128c5-256c5-512f_%s-8000-8000_1_iter_1560001.caffemodel'],...
                            category_name);
                        
net = caffe.Net(params.model_def_file, params.model_file, 'test');
caffe.set_mode_gpu();

fprintf('Loading data from disk...\n');
if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end
tic;
crops_global_info = load(DatasetStructure.getCropsGlobalInfoPath(dataset_path));
toc
fprintf('Calculating category offset...\n');
category_offset = get_category_offset(category_name, data_info);

category_size = 0;
category_id = data_info.categoryLookupTable(category_offset + 1);
while category_offset + 1 + category_size <= data_info.totalNumberOfVectors && ...
       data_info.categoryLookupTable(category_offset + 1 + category_size) == category_id
    category_size = category_size + 1;
end

category_size
number_of_surrogate_classes = 8000;
FEATURE_SIZE = 4 * 8000;
features = zeros(category_size, FEATURE_SIZE, 'single');
features_flip = zeros(category_size, FEATURE_SIZE, 'single');

fprintf('Running forward propagation on %s\n', category_name);
progress_struct = init_progress_string('Image:', category_size, 10);
for i = 1:category_size
    update_progress_string(progress_struct, i);
    
    image = imread(fullfile(crops_path, crops_global_info.crops(category_offset + i).img_relative_path));
    if size(image, 3) < 3
        assert(false, ' Not a 3-channel image!');
        continue;
    end

    features(i, :) = single(compute_image_feature(net, image, number_of_surrogate_classes));
    features_flip(i, :) = single(compute_image_feature(net, utils.fliplr(image), number_of_surrogate_classes));
end
fprintf('\n');

features = zscore(features);
features_flip = zscore(features_flip);

fprintf('features size: %s\n', mat2str(size(features)));
fprintf('features_flip size: %s\n', mat2str(size(features_flip)));
whos features
fprintf('each feature vector size: %s\n', mat2str(size(features(1,:))));
fprintf('Saving on disk...\n');
save(file_to_save, '-v7.3', 'features', 'features_flip');

end

function [quadrant] = get_quadrant(image, quadrant_id)
    assert(all(size(image) == [96, 96 ,3]));
    assert(quadrant_id >= 1 && quadrant_id <=4)
    
    quadrant_side = 96 / 2;
    
    [i, j] = ind2sub([2, 2], quadrant_id);
    i = i - 1;
    j = j - 1;
    quadrant = image(i * quadrant_side + 1: (i + 1) * quadrant_side, ...
                     j * quadrant_side + 1: (j + 1) * quadrant_side, :);
                 
    assert(all(size(quadrant) == [quadrant_side, quadrant_side, 3]))
end

function [patches] = get_quadrant_patches(quadrant)
    quadrant_side = 96 / 2;
    patch_side = 32;
    assert(all(size(quadrant) == [quadrant_side, quadrant_side, 3]))
    
    patches = cell(1, 9);
    [col, row] = meshgrid(0:2);
    stride = 8;
    col = col(:) * stride;
    row = row(:) * stride;
    for i = 1:length(row)
%         fprintf('Patch %d: [%d:%d, %d:%d]\n', i, row(i) + 1, row(i) + patch_side, col(i) + 1, col(i) + patch_side);
        patches{i} = quadrant(row(i) + 1 : row(i) + patch_side, col(i) + 1 : col(i) + patch_side, : );
    end
end

function feature = compute_quadrant_feature(net, quadrant, feature_size)
    [patches] = get_quadrant_patches(quadrant);
    feature = zeros(length(patches), feature_size);
    for i = 1:length(patches)
        nn_output = net.forward(patches(i)); 
        assert(all(size(nn_output{1}, 1) == feature_size));
        
        feature(i, :) = nn_output{1}';
    end
    
    feature = max(feature, [], 1);
end

function feature = compute_image_feature(net, image, number_of_surrogate_classes)
    feature = [];
    for quadrant_id = 1:4
        quadrant = get_quadrant(image, quadrant_id);
        feature = [feature, compute_quadrant_feature(net, quadrant, number_of_surrogate_classes)];
    end
end
