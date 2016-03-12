function [] = run_single_process_training(anchor_global_ids, anchor_flipvals, ...
                                                       previously_trained, ...
                                                       esvm_train_params, ...
                                                       ESVM_MODELS_DIR)
%RUN-SINGLE_PROCESS_TRAINING

for i = 1:length(anchor_global_ids)
    frame_id = anchor_global_ids(i);
    fprintf('----Anchor %d\n', frame_id);
    model_name = sprintf('%06d', frame_id);
    if anchor_flipvals(i)
        model_name = [model_name '_flipped'];
    end
    
    output_dir = fullfile(ESVM_MODELS_DIR, model_name);
    
    has_final_model_file = ~isempty(getFilesInDir([output_dir, '/models'], '.*-svm\.mat')) || ...
                       ~isempty(getFilesInDir(output_dir, '.*-svm\.mat'));
    
    if (has_final_model_file || ...
         any(find(ismember(previously_trained.trained_model_names, model_name))))
        continue;
    elseif exist(output_dir, 'dir') && ~has_final_model_file
        rmdir(output_dir, 's');
    end
    
    assert(anchor_flipvals(i) == 0);
    sim_esvm.train(frame_id, anchor_flipvals(i), output_dir, esvm_train_params);
end

end

