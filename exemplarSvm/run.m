sim_esvm_init;

previously_trained = load(fullfile(dataset_path, 'esvm/esvm_models_all_0.1_round1.mat'));

labels_dir_path = '~/workspace/dataset_labeling/labels_to_train';
[anchor_global_ids, anchor_flipvals] = get_all_labeled_global_anchor_ids(labels_dir_path);

% CLIQUES_FILE_PATH = fullfile(dataset_path, 'exemplar_cnn/multiclass_svm_test/data/100_30_cliques_long_jump.mat');
% CATEGORY_NAME = 'long_jump';
% [anchor_global_ids, anchor_flipvals] = get_global_anchors_from_cliques_file(data_info, CATEGORY_NAME, CLIQUES_FILE_PATH);


for i = 1:length(anchor_global_ids)
    frame_id = anchor_global_ids(i);
    fprintf('----Anchor %d\n', frame_id);
    model_name = sprintf('%06d', frame_id);
    if anchor_flipvals(i)
        model_name = [model_name '_flipped'];
    end
    
    output_dir = fullfile(ESVM_MODELS_DIR, model_name);
    
    if (exist(output_dir, 'dir') || any(find(ismember(previously_trained.trained_model_names, model_name))))
        continue;
    end

    sim_esvm_train(frame_id, anchor_flipvals(i), dataset, data_info, output_dir, esvm_train_params);
end