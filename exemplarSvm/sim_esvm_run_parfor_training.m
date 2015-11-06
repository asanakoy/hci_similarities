p = gcp('nocreate'); % If no pool, then create a new one.
if isempty(p)
    fprintf('Starting parpool with %d workers...\n', ESVM_NUMBER_OF_WORKERS);
    c = parcluster('local');
    c.NumWorkers = ESVM_NUMBER_OF_WORKERS;
    
    if (~strcmp(version('-release'), '2014b'))
        matlabpool(c, c.NumWorkers);
    else
        parpool(c, c.NumWorkers);
    end 
end

parfor i = 1:length(anchor_global_ids)
    frame_id = anchor_global_ids(i);
    fprintf('----Anchor %d\n', frame_id);
    model_name = sprintf('%06d', frame_id);
    if anchor_flipvals(i)
        model_name = [model_name '_flipped'];
    end
    
    output_dir = fullfile(ESVM_MODELS_DIR, model_name);
    
    if (~isempty(getFilesInDir(output_dir, '.*svm-removed_top_hrd\.mat')) || ...
         any(find(ismember(previously_trained.trained_model_names, model_name, 'rows'))))
        continue;
    end
    
%     model_file = load(fullfile(ESVM_MODELS_DIR_PREVIOUS_ROUND, ...
%         sprintf('%06d', frame_id), 'models', sprintf('%06d-svm.mat', frame_id)));
% 
%     sim_esvm_train(frame_id, dataset, data_info, output_dir, TRAIN_DATA_FRACTION, RUN_TEST, model_file.models);
    sim_esvm_train(frame_id, anchor_flipvals(i), dataset, data_info, output_dir, TRAIN_DATA_FRACTION, RUN_TEST);
end