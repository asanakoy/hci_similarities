function [ roc_params ] = get_roc_params()
%GET_ROC_PARAMS Get deafult params for ROC plotting.
addpath(genpath('~/workspace/similarities'))

roc_params.dataset_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports';
roc_params.plots_dir = 'plots';

roc_params.use_cnn_features = 0;% ESVM Uses CNN features or HOG.
roc_params.features_path = ... % used only if use_cnn_features = 1
    '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat';
roc_params.esvm_crops_dir_name = 'crops_227x227';


% Load features into memory
if roc_params.use_cnn_features
    tic;
    fprintf('Reading CNN features file...\n');
    assert(exist(roc_params.features_path, 'file') ~= 0, ...
                'File %s is not found', roc_params.features_path);
    roc_params.features_data = load(roc_params.features_path, 'features', 'features_flip');
    toc
end

roc_params.detect_params = sim_esvm_get_default_params;
if roc_params.use_cnn_features
    roc_params.detect_params.features_type = 'FeatureVector';
    roc_params.esvm_models_dir = 'esvm/alexnet_esvm_models_long_jump';
    roc_params.esvm_name = 'ESVM-alexnet-fc7';
else
    roc_params.detect_params.features_type = 'HOG-like';
    % ESVM_DATA_FRACTION_STR = '0.1';
    % ROUND_STR = '1';
    % roc_params.esvm_models_dir = ['esvm/esvm_models_all_' ESVM_DATA_FRACTION_STR '_round' ROUND_STR];
    roc_params.esvm_models_dir = 'esvm/esvm_long_jump_test';
    roc_params.esvm_name = 'ESVM-HOG';
end


roc_params.data_info = load(DatasetStructure.getDataInfoPath(roc_params.dataset_path));
    
if ~isfield(roc_params.data_info, 'dataset_path')
    roc_params.data_info.dataset_path = roc_params.dataset_path;
end

roc_params.labels_filepath = sprintf(['~/workspace/dataset_labeling'...
                                       '/merged_data_19.02.16/labels_%s.mat'], category_name);

roc_params.path_simMatrix = ['~/workspace/OlympicSports/sim/simMatrix_', category_name, '.mat'];

end

