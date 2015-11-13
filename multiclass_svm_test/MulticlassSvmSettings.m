classdef MulticlassSvmSettings
    properties (Constant)   
        ESVM_MODELS_DIR = 'esvm/esvm_models_all_0.1_round1';
        CROPS_DIR = 'crops_227x227'
    end
    
    properties
        dataset_path = ''
        category_name = ''
        basis_models_handles = cell(0, 1);
        train_fraction = 0.4
        cv_fraction = 0.2
        test_fraction = 0.4
        crops_path = ''
    end
    
    methods
        function obj = MulticlassSvmSettings(dataset_path, basis_models_handles, category_name)
            obj.dataset_path = dataset_path;
            obj.basis_models_handles = basis_models_handles;
            obj.category_name = category_name;
            obj.crops_path = fullfile(dataset_path, obj.CROPS_DIR);
        end
        
        function esvm_models_path = get_esvm_models_path(obj)
            esvm_models_path = fullfile(obj.dataset_path, obj.ESVM_MODELS_DIR);
        end
    end
    
end

