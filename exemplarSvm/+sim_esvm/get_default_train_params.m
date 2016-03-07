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
    '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat'); % used only if use_plain_features = 1

% policy for generating negative samples
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'create_negatives_policy', 'negative_cliques'); 

data_info = load(DatasetStructure.getDataInfoPath(esvm_train_params.dataset_path));

% Use CNN features or HOG.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'use_plain_features', 1);

% Load features from disk or generate online?
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'should_load_features_from_disk', 0);

% Portion of data to use for negative mining.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'negatives_train_data_fraction', 0.1);

% Run test for esvm (together with visualization)?
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'should_run_test', 0);

% Load pathes instead of images. Load images in a lazy way.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'use_image_pathes', 1);

% Train using negative maining or at once(just on all dataset at once)?
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'use_negative_mining', 1);

% How many top hard negatives to remove.
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'remove_top_hard_negatives_fraction', 0.0);

% SVM training type
esvm_train_params = set_field_if_not_exist(esvm_train_params, 'training_type', 'esvm'); % ['esvm', 'clique_svm', 'esvm_positive_clique_embedding']

% Restore lost bin that were deminished after HOG-Pedro calculation.
% Lost bin will be filled with zeros.
esvm_train_params =  set_field_if_not_exist(esvm_train_params, 'restore_hog_lost_bin', 0);

%How much we pad the pyramid (to let detections fall outside the image)
esvm_train_params =  set_field_if_not_exist(esvm_train_params, 'detect_padding', 0);

% Should we just initialize Exemlars and do NOT train them?
esvm_train_params =  set_field_if_not_exist(esvm_train_params, 'should_just_initialize_models', 0);

LABELS_PATH = '~/workspace/dataset_labeling/merged_data_19.02.16/labels_long_jump.mat';
fprintf('Loading labels from %s ...\n', LABELS_PATH);
% Labeled positive and negative frames for each anchor frame.
esvm_train_params.labeled_data = load(LABELS_PATH);

create_data_params.dataset_path = esvm_train_params.dataset_path;
create_data_params.use_plain_features = esvm_train_params.use_plain_features;
create_data_params.data_info = data_info;
create_data_params.negatives_train_data_fraction = esvm_train_params.negatives_train_data_fraction;
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

if esvm_train_params.should_load_features_from_disk == 1
    fprintf('Loading features... from %s\n', esvm_train_params.features_path);
    assert(exist(esvm_train_params.features_path, 'file') ~= 0, ...
            'File %s is not found', esvm_train_params.features_path);
    create_data_params.features_data = load(esvm_train_params.features_path, 'features', 'features_flip');
    assert(isfield(create_data_params.features_data, 'features'));
    assert(isfield(create_data_params.features_data, 'features_flip'));

end

if strcmp(esvm_train_params.create_negatives_policy, 'negative_cliques') ...
        || strcmp(esvm_train_params.training_type, 'clique_svm')
    
     esvm_train_params = set_field_if_not_exist(esvm_train_params, 'cliques_data_path', ...
         '~/workspace/OlympicSports/clique-esvm/data/cliques_data.mat');
     
    assert(exist(esvm_train_params.cliques_data_path, 'file') ~= 0, ...
        'File %s is not found', esvm_train_params.cliques_data_path);
    create_data_params.cliques_data = load(esvm_train_params.cliques_data_path);
end

esvm_train_params.create_data_params = create_data_params;
esvm_train_params.is_inited = 1;

sim_esvm.check_esvm_train_params(esvm_train_params);

end

