function [ roc_params ] = get_roc_params(category_name, models_path)
%GET_ROC_PARAMS Get deafult params for ROC plotting.

roc_params.dataset_path = '~/workspace/OlympicSports';
roc_params.plots_dir = 'plots';

roc_params.use_plain_features = 0;% ESVM Uses Plain features or Spatial.
roc_params.should_load_features_from_disk = 0;
is_single_category_features_file = 0;
roc_params.features_path = ... % used only if use_plain_features = 1
    '~/workspace/OlympicSports/alexnet/features/features_long_jump_imagenet-alexnet_iter_0_conv5.mat';

roc_params.esvm_crops_dir_name = 'crops_227x227';

roc_params.use_models_with_top_hardest_negatives_removed = 0;


roc_params.data_info = load(DatasetStructure.getDataInfoPath(roc_params.dataset_path));
if ~isfield(roc_params.data_info, 'dataset_path')
    roc_params.data_info.dataset_path = roc_params.dataset_path;
end

% Load features into memory
if roc_params.should_load_features_from_disk == 1
    fprintf('Reading CNN features file... %s\n', roc_params.features_path);
    assert(exist(roc_params.features_path, 'file') ~= 0, ...
                'File %s is not found', roc_params.features_path);
    
    category_offset =  get_category_offset(category_name, roc_params.data_info);
    category_size = get_category_size(category_name, roc_params.data_info);
    roc_params.features_data = sim_esvm.FeaturesContainer(roc_params.features_path, ...
                                                 category_offset, category_size, is_single_category_features_file);
end

roc_params.detect_params = sim_esvm.get_default_params;
if roc_params.use_plain_features == 1
    roc_params.detect_params.features_type = 'FeatureVector';
    if exist('models_path', 'var')
        roc_params.esvm_models_dir = models_path;
    else
        roc_params.esvm_models_dir = fullfile(roc_params.dataset_path, ...
            'esvm/hog_pedro_initialization_esvm_model');
    end
    roc_params.esvm_name = 'ESVM-HOG-pedro-init';
else
    roc_params.detect_params.features_type = 'HOG-like';
    if exist('models_path', 'var')
        roc_params.esvm_models_dir = models_path;
    else
        roc_params.esvm_models_dir = 'esvm/alexnet_conv5_post_RELU_initialization_esvm_model';
        roc_params.esvm_models_dir = fullfile(roc_params.dataset_path, roc_params.esvm_models_dir);
    end
    roc_params.esvm_name = 'standard_esvm_HOG_no-pad';
end

roc_params.detect_params.should_load_features_from_disk = roc_params.should_load_features_from_disk;

roc_params.should_use_crops_info = 1; % Use crops_info file to get fetch image patches.
if roc_params.should_use_crops_info == 1
    CROPS_INFO_FILEPATH = fullfile(DatasetStructure.getDataDirPath(roc_params.dataset_path), 'crops_global_info.mat');
    roc_params.crops_info = load(CROPS_INFO_FILEPATH);
end

roc_params.labels_filepath = sprintf(['~/workspace/dataset_labeling'...
                                       '/merged_data_19.02.16/labels_%s.mat'], category_name);

% roc_params.path_simMatrix = ['~/workspace/OlympicSports/sim/simMatrix_', category_name, '.mat'];
roc_params.path_simMatrix = ['~/workspace/OlympicSports/sim_pedro_hog/sim_hog_pedro_', category_name, '.mat'];

end
