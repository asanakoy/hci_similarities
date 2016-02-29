dataset_path = '~/workspace/OlympicSports';

% ESVM_MODELS_DIR_PREVIOUS_ROUND = '~/workspace/OlympicSports/esvm_models_all_0.1_round1';

esvm_train_params.use_cnn_features = 1; % Use CNN features or HOG.
esvm_train_params.features_path = ... % used only if use_cnn_features = 1
    '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat';

esvm_train_params.create_negatives_policy = 'negative_cliques';
esvm_train_params.cliques_data_path = ... % used only with esvm_train_params.create_negatives_policy = 'negative_cliques'
    '%TODO: SETPATH';

esvm_train_params.use_image_pathes = 1; % Load pathes instead of images. Load images in a lazy way.
esvm_train_params.should_run_test = 0; % Run test for esvm (together with visualization)?
esvm_train_params.neg_mining_data_fraction = 0.1; % Portion of data to use for negative mining.

esvm_train_params = sim_esvm.get_default_train_params(esvm_train_params); % add not filled required fields.

ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm/alexnet_esvm_models_output'; % Output dir.

ESVM_NUMBER_OF_WORKERS = 1;