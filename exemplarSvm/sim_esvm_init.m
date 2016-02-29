addpath(genpath('~/workspace/similarities'));
ESVM_LIB_PATH = '~/workspace/exemplarsvm';
addpath(genpath(ESVM_LIB_PATH));

sim_esvm_set_params;

if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? yes/N [N]: ', ESVM_MODELS_DIR);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        rmdir(ESVM_MODELS_DIR, 's');
        fprintf('Deleted %s.\n', ESVM_MODELS_DIR);
    end
end
