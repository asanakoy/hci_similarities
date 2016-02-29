sim_esvm_init;


% previously_trained = load(fullfile(dataset_path, 'esvm/esvm_models_all_0.1_round1.mat'));
previously_trained.trained_model_names = [];
labels_dir_path = '~/workspace/dataset_labeling/labels_to_train';
[anchor_global_ids, anchor_flipvals] = sim_esvm.get_all_labeled_global_anchor_ids(labels_dir_path);

% Run for all long_jump ids
% all_long_jump_ids = [76507:84372]; 
% size(all_long_jump_ids)
% 
% anchor_global_ids = all_long_jump_ids;
% anchor_flipvals = false(size(anchor_global_ids));

% CLIQUES_FILE_PATH = fullfile(dataset_path, 'exemplar_cnn/multiclass_svm_test/data/100_30_cliques_long_jump.mat');
% CATEGORY_NAME = 'long_jump';
% [anchor_global_ids, anchor_flipvals] = sim_esvm.get_global_anchors_from_cliques_file(data_info, CATEGORY_NAME, CLIQUES_FILE_PATH);
% anchor_global_ids = anchor_global_ids(1:100);
% anchor_flipvals = anchor_flipvals(1:100);

if ESVM_NUMBER_OF_WORKERS > 1
    sim_esvm_run_parfor_training;
else
    sim_esvm_run;
end

