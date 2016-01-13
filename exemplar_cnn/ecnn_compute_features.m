function [] = ecnn_compute_features(category_name, data_info)
%COMPUTECNNFEATURES Summary of this function goes here
%   Detailed explanation goes here

addpath(genpath('/export/home/asanakoy/workspace/similarities'));
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

%check file existance
pathsave = '/export/home/asanakoy/workspace/OlympicSports/exemplar_cnn/features/fc7';
file_to_save = fullfile(pathsave,[model,'_',category_name,'_Features_fc7_15_patches.mat']);
if exist(file_to_save, 'file')
    fprintf('Skip. File %s already exists!\n', file_to_save);
    fprintf('Loading and resaving in format -v7.3\n');
    load(file_to_save);
    save(file_to_save, '-v7.3', 'conv3');
    return
end

% init network
params.model_def_file = [HOME '/workspace/similarities/exemplar_cnn/deploy_',model,'.prototxt'];
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
fc7 = cell(category_size, 1);

fprintf('Running forward propagation on %s\n', category_name);
progress_struct = init_progress_string('Image:', category_size, 50);
for i = 1:category_size
    
    update_progress_string(progress_struct, i);
    image = imread(fullfile(crops_path, crops_global_info.crops(category_offset + i).img_relative_path));
    if size(image, 3) < 3
        assert(false, ' Not a 3-channel image!');
        continue;
    end
    
    patches = ecnn_get_random_patches(image);
    feature_vector = [];
    for current_patch = patches
        nn_output = net.forward(current_patch); 
        feature_vector = [feature_vector; nn_output{1}];
    end
    fc7{i} = feature_vector;

end
fprintf('\n');

fprintf('fc7 data size: %d x %d', size(fc7,1), size(fc7,2));
whos fc7
fprintf('each feature vector size: %s\n', mat2str(size(fc7{1})));
fprintf('Saving on disk...\n');
save(file_to_save, '-v7.3', 'fc7');

end
