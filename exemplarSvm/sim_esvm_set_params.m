dataset_path = '~/workspace/OlympicSports';

% ESVM_MODELS_DIR_PREVIOUS_ROUND = '~/workspace/OlympicSports/esvm_models_all_0.1_round1';

if ~exist('esvm_train_params', 'var') ...
   || ~isfield(esvm_train_params, 'is_inited') || esvm_train_params.is_inited ~= 1
    fprintf('Setting train params...');
    esvm_train_params = struct();
    esvm_train_params.dataset_path = dataset_path;
    esvm_train_params.use_cnn_features = 0; % Use CNN features or HOG.
    esvm_train_params.features_path = ... % used only if use_cnn_features = 1
        '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat';
    
    % Policy to create negative samples. 
    % Values: ['random_from_other_categories', 'negative_cliques']
    esvm_train_params.create_negatives_policy = 'random_from_other_categories'; 
    esvm_train_params.cliques_data_path = ... % used only with esvm_train_params.create_negatives_policy = 'random_from_other_categories'
       '~/workspace/OlympicSports/clique-esvm/data/cliques_data.mat';


    esvm_train_params.use_image_pathes = 1; % Load pathes instead of images. Load images in a lazy way.
    esvm_train_params.should_run_test = 0; % Run test for esvm (together with visualization)?
    esvm_train_params.neg_mining_data_fraction = 0.1; % Portion of data to use for negative mining.

    esvm_train_params = sim_esvm.get_default_train_params(esvm_train_params); % add not filled required fields.
end

ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm/esvm_long_jump_test'; % Output dir.

ESVM_NUMBER_OF_WORKERS = 1;
