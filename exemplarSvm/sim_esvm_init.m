addpath(genpath(Config.SELF_ROOT));

sim_esvm_set_params;

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

