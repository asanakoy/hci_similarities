function [ result ] = get_roc( dataset_path, category_name )
%GET_ROC Summary of this function goes here
%   Detailed explanation goes here
result = [];

% roc_params = get_ucf_roc_params(category_name, dataset_path, {'SIM_hog_pedro'});
% result = [result, sim_esvm_get_roc(category_name, roc_params)];
% 
% roc_params = get_ucf_roc_params(category_name, dataset_path, {'SIM_alexnet_fc7'});
% result = [result, sim_esvm_get_roc(category_name, roc_params)];

roc_params = get_ucf_roc_params(category_name, dataset_path, {'ESVM'});
result = [result, sim_esvm_get_roc(category_name, roc_params)];

end

function [ roc_params ] = get_ucf_roc_params(category_name, dataset_path, models_to_test)
%GET_ROC_PARAMS Get deafult params for ROC plotting.

roc_params.dataset_path = dataset_path;
roc_params.models_to_test = models_to_test;
roc_params.plots_dir = 'plots';
roc_params.esvm_crops_dir_name = 'crops_227x227';

roc_params.use_plain_features = 0;% ESVM Uses Plain features or Spatial.
roc_params.should_load_features_from_disk = 0;
roc_params.use_models_with_top_hardest_negatives_removed = 0;


roc_params.data_info = load(DatasetStructure.getDataInfoPath(roc_params.dataset_path));
if ~isfield(roc_params.data_info, 'dataset_path')
    roc_params.data_info.dataset_path = roc_params.dataset_path;
end

detect_params = sim_esvm.get_default_params;
if roc_params.use_plain_features == 1
    detect_params.features_type = 'FeatureVector';
    roc_params.esvm_models_dir = '~/tmp/test';
    roc_params.esvm_name = 'ESVM-fc7';
else
    detect_params.features_type = 'HOG-like';
    roc_params.esvm_models_dir = ['esvm/standard_esvm_no-pad_mining_1_models_', ...
                                   category_name, '_1.0-random_from_other_categories_c0.01_Wpos50'];
    roc_params.esvm_models_dir = fullfile(roc_params.dataset_path, roc_params.esvm_models_dir);
    roc_params.esvm_name = 'standard_esvm_HOG_no-pad_1.0-random_from_other_categories';
end
detect_params.should_load_features_from_disk = roc_params.should_load_features_from_disk;

roc_params.should_use_crops_info = 1; % Use crops_info file to get fetch image patches.
if roc_params.should_use_crops_info == 1
    CROPS_INFO_FILEPATH = fullfile(DatasetStructure.getDataDirPath(roc_params.dataset_path), 'crops_global_info.mat');
    roc_params.crops_info = load(CROPS_INFO_FILEPATH);
end

roc_params.labels_filepath = fullfile(dataset_path, ...
                                      sprintf('dataset_labeling/merged_data_last/labels_%s.mat', category_name));

roc_params.path_simMatrix = '';
if strcmp(models_to_test{1}, 'SIM_hog_pedro')
    roc_params.path_simMatrix = ['sim_pedro_hog/sim_hog_pedro_', category_name, '.mat'];
elseif strcmp(models_to_test{1}, 'SIM_alexnet_fc7')
    roc_params.path_simMatrix = ['alexnet/sim_matrices/simMatrix_', category_name, '_imagenet-alexnet_iter_0_fc7.mat'];
end
roc_params.path_simMatrix = fullfile(dataset_path, roc_params.path_simMatrix);
    
roc_params.detect_params = detect_params;
end
