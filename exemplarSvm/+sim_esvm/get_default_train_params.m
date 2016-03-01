function [ esvm_train_params ] = get_default_train_params(esvm_train_params)
%GET_DEFAULT_TRAIN_PARAMS Returns default esvm_train_params for training ESVM
%   NOTE: can be havy operation. Because it loads data into the memory.
% This is esvm_train_params
% WARNING: Do not set esvm_train_params.create_data_params from outside!

%% Setting esvm_train_params
% =========================================================================
if ~exist('esvm_train_params', 'var')
    esvm_train_params = struct();
end

assert(~isfield(esvm_train_params, 'create_data_params'), 'Do not set esvm_train_params.create_data_params from outside!');

esvm_train_params = set_field_if_not_exist(esvm_train_params, 'dataset_path', '~/workspace/OlympicSports');
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'features_path', ... 
    '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat'); % used only if use_cnn_features = 1

% policy for generating negative samples
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'create_negatives_policy', 'negative_cliques'); 
if strcmp(esvm_train_params.create_negatives_policy, 'negative_cliques')
    %TODO: set cliques_data_path
    esvm_train_params = set_field_if_not_exist(esvm_train_params, 'cliques_data_path', '~/workspace/OlympicSports/clique-esvm/data/cliques_data.mat');
end


data_info = load(DatasetStructure.getDataInfoPath(esvm_train_params.dataset_path));

% Use CNN features or HOG.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'use_cnn_features', 1);

% Portion of data to use for negative mining.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'neg_mining_data_fraction', 0.1);

% Run test for esvm (together with visualization)?
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'should_run_test', 0);

% Load pathes instead of images. Load images in a lazy way.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'use_image_pathes', 1);



create_data_params.dataset_path = esvm_train_params.dataset_path;
create_data_params.use_cnn_features = esvm_train_params.use_cnn_features;
create_data_params.data_info = data_info;
create_data_params.neg_mining_data_fraction = esvm_train_params.neg_mining_data_fraction;
% policy for generating negative samples
create_data_params.create_negatives_policy = esvm_train_params.create_negatives_policy;  


tic;
if esvm_train_params.use_image_pathes
    fprintf('Opening crops global info file...\n');
    CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(esvm_train_params.dataset_path), 'crops_global_info.mat');
else
    fprintf('Opening all crops file...\n');
    CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(esvm_train_params.dataset_path), 'crops_227x227.mat');
end
create_data_params.crops_global_info = load(CROPS_ARRAY_FILEPATH);
toc

if esvm_train_params.use_cnn_features == 1
    fprintf('Loading features...\n');
    assert(exist(esvm_train_params.features_path, 'file') ~= 0, ...
            'File %s is not found', esvm_train_params.features_path);
    create_data_params.features_data = load(esvm_train_params.features_path, 'features', 'features_flip');
    assert(isfield(create_data_params.features_data, 'features'));
    assert(isfield(create_data_params.features_data, 'features_flip'));

end

if strcmp(create_data_params.create_negatives_policy, 'negative_cliques')
    assert(exist(esvm_train_params.cliques_data_path, 'file') ~= 0, ...
        'File %s is not found', esvm_train_params.cliques_data_path);
    % TODO: load negative_cliques
    % create_data_params.negative_cliques = load(esvm_train_params.cliques_data_path)
end

esvm_train_params.create_data_params = create_data_params;
esvm_train_params.is_inited = 1;

sim_esvm.check_esvm_train_params(esvm_train_params);

end

