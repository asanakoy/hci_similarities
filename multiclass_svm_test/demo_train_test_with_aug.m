addpath(genpath('~/workspace/similarities'));
addpath(genpath('~/workspace/exemplarsvm'));

TRAIN_DATA_FILEPATH = '~/workspace/OlympicSports/exemplar_cnn/multiclass_svm_test/data_augmented/held_back_13_cliques_train.mat';
TEST_DATA_FILEPATH = '~/workspace/OlympicSports/exemplar_cnn/multiclass_svm_test/data_augmented/held_back_13_cliques_test.mat';
DATASET_PATH = '~/workspace/OlympicSports/';
CATEGORY_NAME = 'long_jump';
GLOABL_ANCHORS_FILEPATH = '~/workspace/OlympicSports/exemplar_cnn/multiclass_svm_test/data/100_30_cliques_long_jump_Global_anchors.mat';

basis_models_handles = get_anchors_handles( GLOABL_ANCHORS_FILEPATH );
NUMBER_OF_BATCHES = 1;
BATCH_SIZE = 100;
basis_models_handles = basis_models_handles(1:NUMBER_OF_BATCHES * BATCH_SIZE);


settings = MulticlassSvmSettings(DATASET_PATH, basis_models_handles, CATEGORY_NAME)

if ~exist('train_data_aug', 'var') || ~exist('test_data_aug', 'var')
    fprintf('Generating data\n');
    train_data_aug = generate_data_augmented( settings, TRAIN_DATA_FILEPATH );
    fprintf('Train data generated\n');
    test_data_aug = generate_data_augmented( settings, TEST_DATA_FILEPATH );
    fprintf('Test data generated\n');
else
    fprintf('Using pregenerated data\n');
end

kernel_type = 0; % linear
multiclass_svm_train_and_test(train_data_aug, test_data_aug, kernel_type);