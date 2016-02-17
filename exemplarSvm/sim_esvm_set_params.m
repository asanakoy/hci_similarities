dataset_path = '~/workspace/OlympicSports';

% ESVM_MODELS_DIR_PREVIOUS_ROUND = '~/workspace/OlympicSports/esvm_models_all_0.1_round1';

esvm_train_params.use_cnn_features = 1; % Use CNN features or HOG.
esvm_train_params.cnn_features_path = ... % used only if use_cnn_features = 1
    '~/workspace/OlympicSports/alexnet/features/alexnet_long_jump_Features_fc7.mat';

esvm_train_params.use_image_pathes = 1; % Load pathes instead of images. Load images in a lazy way.
esvm_train_params.should_run_test = 0; % Run test for esvm (together with visualization)?
esvm_train_params.train_data_fraction = 0.1; % Portion of data to use for negative mining.
ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm/esvm_models_output'; % Output dir.

ESVM_NUMBER_OF_WORKERS = 16;