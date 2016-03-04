function [aucs] = sim_esvm_many_run( create_negatives_policy, negatives_train_data_fraction, use_mining )
%SIM_ESVM_MANY_RUN Summary of this function goes here
%   Detailed explanation goes here

c_vals = [0.01, 1, 10];%logspace(-3, 6, 15);
pos_class_constants = [0.001, 1, 1000];
aucs = [];

addpath(genpath('~/workspace/similarities'));
ESVM_LIB_PATH = '~/workspace/exemplarsvm';
addpath(genpath(ESVM_LIB_PATH));

%% Set params
dataset_path = '~/workspace/OlympicSports';


if ~exist('esvm_train_params', 'var') ...
   || ~isfield(esvm_train_params, 'is_inited') || esvm_train_params.is_inited ~= 1
    fprintf('Setting train params...');
    esvm_train_params = struct();
    esvm_train_params.dataset_path = dataset_path;
    esvm_train_params.use_cnn_features = 1; % Use CNN features or HOG.
    esvm_train_params.features_path = ... % used only if use_cnn_features = 1
        '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7_zscores.mat';
    
    % Policy to create negative samples. 
    % Values: ['random_from_other_categories', random_from_same_category, 'negative_cliques']
    esvm_train_params.create_negatives_policy = create_negatives_policy; 
    esvm_train_params.cliques_data_path = ... % used only with esvm_train_params.create_negatives_policy = 'random_from_other_categories'
       '~/workspace/OlympicSports/clique-esvm/data/cliques_long_jump.mat';

    esvm_train_params.use_image_pathes = 1; % Load pathes instead of images. Load images in a lazy way.
    esvm_train_params.should_run_test = 0; % Run test for esvm (together with visualization)?
    esvm_train_params.negatives_train_data_fraction = negatives_train_data_fraction; % Portion of data to use for training.
    esvm_train_params.use_negative_mining = use_mining; % Train at once or use mining?
    esvm_train_params.remove_top_hard_negatives_fraction = 0.0; % How many top hard negatives to remove.
    esvm_train_params.training_type = 'esvm';

    esvm_train_params = sim_esvm.get_default_train_params(esvm_train_params); % add not filled required fields.
end
ESVM_NUMBER_OF_WORKERS = 1;


if use_mining == 0
    mining_str = 'at once';
else
    mining_str = 'mining';
end

for svm_c = c_vals
    esvm_train_params.train_svm_c = svm_c;
    
    for pos_class_mult = pos_class_constants
        esvm_train_params.positive_class_weight_multiplier = pos_class_mult;

        
        C_pos = esvm_train_params.train_svm_c * esvm_train_params.positive_class_weight_multiplier;
        C_neg = esvm_train_params.train_svm_c;
        
        %% Init dirs
        ESVM_MODELS_DIR = sprintf(['~/workspace/OlympicSports/esvm/'...
            'alexnet_zscores_esvm_%s_models_long_jump_%s_Cpos%s_Cneg%s/'], ...
            mining_str, ...
            esvm_train_params.create_negatives_policy, ...
            num2str(C_pos), num2str(C_neg)); % Output dir.

        if exist(ESVM_MODELS_DIR, 'dir')
            rmdir(ESVM_MODELS_DIR, 's');
            fprintf('Deleted %s.\n', ESVM_MODELS_DIR);
            mkdir(ESVM_MODELS_DIR);
        else
            mkdir(ESVM_MODELS_DIR);
        end
        struct2File(esvm_train_params, fullfile(ESVM_MODELS_DIR, 'esvm_train_params.txt'), 'align', true);
        struct2File(esvm_train_params.create_data_params, ...
            fullfile(ESVM_MODELS_DIR, 'esvm_train_params.create_data_params.txt'),  'align', true);


        previously_trained.trained_model_names = [];
        labels_dir_path = '~/workspace/dataset_labeling/labels_to_train';
        [anchor_global_ids, anchor_flipvals] = sim_esvm.get_all_labeled_global_anchor_ids(labels_dir_path);


        if ESVM_NUMBER_OF_WORKERS > 1
            sim_esvm_run_parfor_training;
        else
            sim_esvm_run;
        end

        fprintf('Cleaning model folders...\n');
        ret_code = system(sprintf('sh ~/workspace/OlympicSports/esvm/clean_esvm_folders.sh %s', ESVM_MODELS_DIR));
        assert(ret_code == 0);

        category_name = 'long_jump';
        roc_params = get_roc_params(category_name, ESVM_MODELS_DIR);
        esvm_auc = sim_esvm_get_roc(category_name, roc_params);
        
        fprintf('Category: %s\n', category_name);
        fprintf('Policy: %s. neg_train_data_frac: %.2f. C_pos: %.4f. C_neg: %.4f. AUC: %.4f\n', ...
            esvm_train_params.create_negatives_policy, ...
            esvm_train_params.negatives_train_data_fraction, ...
            esvm_train_params.train_svm_c * esvm_train_params.positive_class_weight_multiplier, ...
            esvm_train_params.train_svm_c, ...
            esvm_auc);
        
        res.auc = esvm_auc;
        res.C = esvm_train_params.train_svm_c;
        res.pos_class_mult = esvm_train_params.positive_class_weight_multiplier;
        aucs = [aucs res];
        
        save(fullfile(ESVM_MODELS_DIR, 'cur_validation.mat'), '-v7.3', 'aucs');
    end
end

end

