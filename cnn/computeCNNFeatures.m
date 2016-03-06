function [] = computeCNNFeatures(category_name, data_info)
%COMPUTECNNFEATURES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '~/workspace/OlympicSports';

CAFFE_ROOT = getenv('CAFFE_ROOT');
HOME = getenv('HOME');
if isempty(CAFFE_ROOT)
    error('CAFFE_ROOT environment variable is not set up!');
end
addpath(fullfile(CAFFE_ROOT, 'matlab'));

crops_path = fullfile(dataset_path, 'crops_96x96');

%load images
models = {'exemplar_cnn'};
model = models{1};

%check file existance
pathsave = '~/workspace/OlympicSports/exemplar_cnn/features';
file_to_save = fullfile(pathsave,[model,'_',category_name,'_Features_conv3.mat']);
if exist(file_to_save, 'file')
    fprintf('Skip. File %s already exists!\n', file_to_save);
    fprintf('Loading and resaving in format -v7.3\n');
    load(file_to_save);
    save(file_to_save, '-v7.3', 'conv3');
    return
end

% init network
params.model_def_file = [HOME '/workspace/similarities/cnn/deploy_',model,'_conv3.prototxt'];
params.model_file = sprintf([HOME '/workspace/OlympicSports/exemplar_cnn/models/'...
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
conv3 = cell(category_size, 1);

fprintf('Running forward propagation on %s\n', category_name);
progress_struct = init_progress_string('Image:', category_size, 50);
for i = 1:category_size
    
    update_progress_string(progress_struct, i);
    image = imread(fullfile(crops_path, crops_global_info.crops(category_offset + i).img_relative_path));
    if size(image, 3) < 3
        assert(false, ' Not a 3-channel image!');
        continue;
    end
%     curr_nn_maps = net.forward({imresize(im8age(:,end:-1:1,:),[imsize,imsize])});
%     net.blobs('data').reshape([size(image) 1]);
    curr_nn_maps = net.forward({image});
    
    
    nn_output = curr_nn_maps{1};
    feat = nn_output;
    conv3{i} = feat;
end
fprintf('\n');

fprintf('conv3 data size: %d x %d', size(conv3,1), size(conv3,2));
whos conv3
fprintf('Saving on disk...\n');
save(file_to_save, '-v7.3', 'conv3');

end

