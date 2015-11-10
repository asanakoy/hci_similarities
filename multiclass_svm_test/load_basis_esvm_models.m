function [basis_models] = load_basis_esvm_models(basis_models_handles, esvm_models_path)

    basis_models = cell(1, length(basis_models_handles));
    
    for i = 1:length(basis_models_handles)
        model_filename = getFilesInDir(fullfile(esvm_models_path, basis_models_handles{i}), '.*-svm\.mat');
        
        if length(model_filename) ~= 1
            if isempty(model_filename) 
                error('No model in dir %s', fullfile(esvm_models_path, basis_models_handles{i}));
            else
                error('Too many models in dir %s', fullfile(esvm_models_path, basis_models_handles{i}));
            end
        end
        
        file = load(fullfile(esvm_models_path, basis_models_handles{i}, model_filename{1}));
        if iscell(file.models)
            file.models = file.models{:};
        end
        assert(length(file.models) == 1);
        basis_models{i} = file.models(1);
    end
end