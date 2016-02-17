addpath(genpath('~/workspace/similarities'));
addpath(genpath('~/workspace/exemplarsvm'));

MULTICLASS_SVM_DIR = '~/workspace/OlympicSports/multiclass_svm_test';
DATASET_PATH = '~/workspace/OlympicSports/';
CATEGORY_NAME = 'long_jump';

CLIQUES_FILEPATH = fullfile(MULTICLASS_SVM_DIR, 'data/13_1_cliques_long_jump.mat');
% Path to fle containing ids of basis anchors
GLOBAL_ANCHORS_FILEPATH = fullfile(MULTICLASS_SVM_DIR, 'data/100_30_cliques_long_jump_Global_anchors.mat');

TRAIN_DATA_AUG_FILEPATH = fullfile(MULTICLASS_SVM_DIR, 'data_augmented/held_back_13_cliques_train.mat');
TEST_DATA_AUG_FILEPATH = fullfile(MULTICLASS_SVM_DIR, 'data_augmented/held_back_13_cliques_test.mat');

ALEXNET_FEATURES_FILEPATH = '/net/hciserver03/storage/mbautist/Desktop/mbautista/Exemplar_CNN/features/actionnet_long_jump_Features_FC7.mat';
ALEXNET_FEATURES_FLIPPED_FILEPATH = '/net/hciserver03/storage/mbautist/Desktop/mbautista/Exemplar_CNN/features/actionnet_long_jump_Features_FC7_flipped.mat';


basis_models_handles = get_anchors_handles( GLOBAL_ANCHORS_FILEPATH );
NUMBER_OF_BATCHES = 1;
BATCH_SIZE = 100;
basis_models_handles = basis_models_handles(1:NUMBER_OF_BATCHES * BATCH_SIZE);


settings = MulticlassSvmSettings(DATASET_PATH, basis_models_handles, CATEGORY_NAME);


%% data without augmentation
% Feature vector - vector of scores of basis ESMVs
train_cv_test_data_path = fullfile(MULTICLASS_SVM_DIR, 'data.mat');
if ~exist('train_data', 'var') || ~exist('test_data', 'var') || ~exist('cv_data', 'var')
    if exist(train_cv_test_data_path, 'file')
        load(train_cv_test_data_path);
    else
        fprintf('Generating data\n');
        [train_data, cv_data, test_data] = generate_data( settings, CLIQUES_FILEPATH );
        save(train_cv_test_data_path , '-v7.3', 'train_data', 'cv_data', 'test_data');
    end
else
    fprintf('Using pregenerated data\n');
end


%% data from cnn layer
% Feature vector - output of Alexnet fc7 layer.
train_cv_test_data_cnn_path = fullfile(MULTICLASS_SVM_DIR, 'data_cnn.mat');
if ~exist('train_data_cnn', 'var') || ~exist('test_data_cnn', 'var') || ~exist('cv_data_cnn', 'var')
    if exist(train_cv_test_data_cnn_path, 'file')
        load(train_cv_test_data_cnn_path);
    else
        fprintf('Generating cnn data\n');
        [train_data_cnn, cv_data_cnn, test_data_cnn] = generate_data_alexnet_features(settings, CLIQUES_FILEPATH,...            
                                                        ALEXNET_FEATURES_FILEPATH, ALEXNET_FEATURES_FLIPPED_FILEPATH);
        fprintf('Data cnn generated\n');
        save(train_cv_test_data_cnn_path , '-v7.3', 'train_data_cnn', 'cv_data_cnn', 'test_data_cnn');
    end
else
    fprintf('Using pregenerated cnn data\n');
end

%% data with augmentation
% Feature vector - vector of scores of basis ESMVs. Using augmented data.
tic;
train_cv_test_data_aug_path = fullfile(MULTICLASS_SVM_DIR, 'data_aug.mat');
if ~exist('train_data_aug', 'var') || ~exist('test_data_aug', 'var') || ~exist('cv_data_aug', 'var')
    if exist(train_cv_test_data_aug_path, 'file')
        load(train_cv_test_data_aug_path);
    else
        fprintf('Generating aug data\n');
        [train_data_aug, cv_data_aug] = generate_train_cv_data_augmented( settings, TRAIN_DATA_AUG_FILEPATH);
        fprintf('Train and cv aug data generated\n');
        test_data_aug = generate_data_augmented( settings, TEST_DATA_AUG_FILEPATH );
        fprintf('Test aug data generated\n');
        save(train_cv_test_data_aug_path , '-v7.3', 'train_data_aug', 'cv_data_aug', 'test_data_aug');
    end
else
    fprintf('Using pregenerated aug data\n');
end
toc