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

file_to_save = fullfile(output_dir, sprintf('features_%s_ecnn_fc5_15patches_zscores.mat', category_name));
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
FEATURE_SIZE = 15 * 8000;
features = zeros(category_size, FEATURE_SIZE, 'single');
features_flip = zeros(category_size, FEATURE_SIZE, 'single');

fprintf('Running forward propagation on %s\n', category_name);
progress_struct = init_progress_string('Image:', category_size, 50);
for i = 1:category_size
    
    update_progress_string(progress_struct, i);
    image = imread(fullfile(crops_path, crops_global_info.crops(category_offset + i).img_relative_path));
    if size(image, 3) < 3
        assert(false, ' Not a 3-channel image!');
        continue;
    end
    
    patches = exemplar_cnn.get_random_patches(image);
    
    feature_vector = [];
    for current_patch = patches
        nn_output = net.forward(current_patch); 
        feature_vector = [feature_vector, nn_output{1}'];
    end
    features(i, :) = single(feature_vector);
    
    feature_vector_flip = [];
    for current_patch = patches
        nn_output = net.forward(utils.fliplr(current_patch)); 
        feature_vector_flip = [feature_vector_flip, nn_output{1}'];
    end
    features_flip(i, :) = single(feature_vector_flip);

end
fprintf('\n');

features = zscore(features);
features_flip = zscore(features_flip);

fprintf('features data size: %s\n', mat2str(size(features)));
fprintf('features_flip data size: %s\n', mat2str(size(features_flip)));
whos features
fprintf('each feature vector size: %s\n', mat2str(size(features(1,:))));
fprintf('Saving on disk...\n');
save(file_to_save, '-v7.3', 'features', 'features_flip');

end
