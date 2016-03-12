function [esvm_train_params, ESVM_MODELS_DIR, labels_dir_path] = init(dataset_path, positive_category_name)
%INIT Summary of this function goes here

% ESVM_MODELS_DIR_PREVIOUS_ROUND = '~/workspace/OlympicSports/esvm_models_all_0.1_round1';

if ~exist('esvm_train_params', 'var') ...
   || ~isfield(esvm_train_params, 'is_inited') || esvm_train_params.is_inited ~= 1
    fprintf('Setting train params...');
    esvm_train_params = struct();
    esvm_train_params.dataset_path = dataset_path;
    esvm_train_params.positive_category_name = positive_category_name;
    esvm_train_params.use_plain_features = 0; % Use plain features or spatial (like HOG).
    esvm_train_params.should_load_features_from_disk = 0;
    esvm_train_params.is_single_category_features_file = 0;
    esvm_train_params.features_path = ... % used only if should_load_features_from_disk = 1
        fullfile(dataset_path, 'alexnet/features/features_long_jump_imagenet-alexnet_iter_0_conv5.mat');
    
    % Policy to create negative samples. 
    % Values: ['random_from_other_categories', random_from_same_category, 'negative_cliques']
    esvm_train_params.create_negatives_policy = 'random_from_other_categories'; 
    esvm_train_params.cliques_data_path = ... % used only with esvm_train_params.create_negatives_policy = 'random_from_other_categories'
       fullfile(dataset_path, 'clique-esvm/data/cliques_', positive_category_name, '.mat');


    esvm_train_params.use_image_pathes = 1; % Load pathes instead of images. Load images in a lazy way.
    esvm_train_params.should_run_test = 0; % Run test for esvm (together with visualization)?
    esvm_train_params.negatives_train_data_fraction = 0.1; % Portion of data to use for training.
    esvm_train_params.use_negative_mining = 1; % Train at once or use mining?
    esvm_train_params.remove_top_hard_negatives_fraction = 0; % How many top hard negatives to remove.
    esvm_train_params.training_type = 'esvm'; % ['esvm', 'clique_svm', 'pos_svm']
    
    esvm_train_params.detect_padding = 0;
    
    esvm_train_params.should_just_initialize_models = 0; % Should we just initialize Exemlars and do NOT train them?

    esvm_train_params = sim_esvm.get_default_train_params(esvm_train_params); % add not filled required fields.
end

esvm_train_params.train_svm_c = 0.01;
esvm_train_params.positive_class_svm_weight = 50;
esvm_train_params.auto_weight_svm_classes = 0;

labels_dir_path = fullfile(dataset_path, sprintf('dataset_labeling/merged_data_last/labels_%s.mat', positive_category_name));

esvm_train_params
esvm_train_params.create_data_params
% fprintf('Press any key to continue.');
% pause;

ESVM_MODELS_DIR = fullfile(dataset_path, ...
    sprintf('esvm/standard_esvm_no-pad_mining_%d_models_%s_%.1f-%s_c%s_Wpos%d/', ...
    esvm_train_params.use_negative_mining, ...
    esvm_train_params.positive_category_name, ...
    esvm_train_params.negatives_train_data_fraction, ...
    esvm_train_params.create_negatives_policy, ...
    num2str(esvm_train_params.train_svm_c), ...
    esvm_train_params.positive_class_svm_weight)); % Output dir.


if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? yes/N [N]: ', ESVM_MODELS_DIR);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        rmdir(ESVM_MODELS_DIR, 's');
        fprintf('Deleted %s.\n', ESVM_MODELS_DIR);
        mkdir(ESVM_MODELS_DIR);
    end
else
    mkdir(ESVM_MODELS_DIR);
end

struct2File(esvm_train_params, fullfile(ESVM_MODELS_DIR, 'esvm_train_params.txt'), 'align', true);
struct2File(esvm_train_params.create_data_params, ...
    fullfile(ESVM_MODELS_DIR, 'esvm_train_params.create_data_params.txt'),  'align', true);



end

