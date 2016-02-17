addpath(genpath('~/workspace/similarities'));

sim_esvm_set_params;

if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? yes/N [N]: ', ESVM_MODELS_DIR);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        rmdir(ESVM_MODELS_DIR, 's');
        fprintf('Deleted %s.\n', ESVM_MODELS_DIR);
    end
end

if ~exist('dataset', 'var')
    tic;
    fprintf('Reading dataset file...\n');
    if esvm_train_params.use_image_pathes
        CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info.mat');
    else
        CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_227x227.mat');
    end
    dataset = load(CROPS_ARRAY_FILEPATH);
    toc
end

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

% Load features into memory
if esvm_train_params.use_cnn_features && ~isfield(esvm_train_params, 'features_data')
    tic;
    fprintf('Reading features file...\n');
    assert(exist(esvm_train_params.cnn_features_path, 'file') ~= 0, ...
                'File %s is not found', esvm_train_params.cnn_features_path);
    esvm_train_params.features_data = load(esvm_train_params.cnn_features_path, 'features', 'features_flip');
    toc
end