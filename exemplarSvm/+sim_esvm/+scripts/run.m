function [ESVM_MODELS_DIR] = run(category_name, ESVM_NUMBER_OF_WORKERS)
%RUN Summary of this function goes here
log_path = sprintf('~/tmp/standard_esvm_log_%s.txt', category_name);
system(sprintf('mv %s %s.old', log_path, log_path));
diary(log_path);

[esvm_train_params, ESVM_MODELS_DIR, labels_dir_path] = sim_esvm.scripts.init(category_name);

[anchor_global_ids, anchor_flipvals] = sim_esvm.get_all_labeled_global_anchor_ids(labels_dir_path);

previously_trained.trained_model_names = {};

if ESVM_NUMBER_OF_WORKERS > 1
    sim_esvm.scripts.run_parallel_training(anchor_global_ids, anchor_flipvals, ...
                                           previously_trained, ...
                                           esvm_train_params, ...
                                           ESVM_MODELS_DIR, ESVM_NUMBER_OF_WORKERS);
else
    sim_esvm.scripts.run_single_process_training(anchor_global_ids, anchor_flipvals, ...
                                                 previously_trained, ...
                                                 esvm_train_params, ...
                                                 ESVM_MODELS_DIR);
end

fprintf('Cleaning model folders...\n');
ret_code = system(sprintf('sh ~/workspace/OlympicSports/esvm/clean_esvm_folders.sh %s', ESVM_MODELS_DIR));
assert(ret_code == 0);

diary off

end

