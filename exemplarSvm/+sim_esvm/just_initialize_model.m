% Just initialize Exemlar. Do not train it.
% Set W = feature - mean(feature(:)), 
%     b = 0.
%
% Return: {model}.
%
% Copyright (C) 2015-16 by Artsiom Sanakoyeu
% All rights reserved. 
function [initial_models] = just_initialize_model(anchor_id, anchor_flipval, output_dir, ...
                                     esvm_train_params)

narginchk(3, 4);
assert(esvm_train_params.should_just_initialize_models == 1);
assert(all(anchor_flipval == 0), 'Anchor flipval is not zero!');
assert(length(anchor_id) == 1 && length(anchor_flipval) == 1);
sim_esvm.check_esvm_train_params(esvm_train_params);

data_info = esvm_train_params.create_data_params.data_info;

category_name = data_info.categoryNames{data_info.categoryLookupTable(anchor_id)};
esvm_train_params.create_data_params.positive_category_name = category_name;
esvm_train_params.create_data_params.positive_category_offset = get_category_offset(category_name, data_info);


fprintf('->sim_esvm.just_init_models ...\n')

model_name = sprintf('%06d', anchor_id); % category name


%% Set exemplar-initialization parameters
params = sim_esvm.get_default_params;
%if localdir is not set, we do not dump files
params.dataset_params.localdir = output_dir;

%================ Set params passed from outside =====================
params = sim_esvm.update_esvm_params(params, esvm_train_params);
params.dump_images = 0;
params.dataset_params.display = 0;
%======================================================================

%%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 10;
stream_params.must_have_seg = 0;
stream_params.must_have_seg_string = '';
stream_params.model_type = 'exemplar'; %must be scene or exemplar
stream_params.cls = category_name;

%assign pos_set as variable, because we need it for visualization
stream_params.pos_set = sim_esvm.create_dataset(anchor_id, esvm_train_params.create_data_params, 0) ;
assert(length(stream_params.pos_set) == 1);

%% Get the positive stream
e_stream_set = esvm_get_pascal_stream(stream_params, ...
                                      params.dataset_params);

%% Initialize Exemplars
initial_models = esvm_initialize_exemplars(e_stream_set, params, ...
                                       model_name);
                                                           
fprintf('Saving models...\n');
save_models(initial_models, params);

end

function save_models(models, params)
   %% Remove the hardest negatives
        filer2 = fullfile(params.dataset_params.localdir, [models{1}.models_name '-svm.mat']);
%         %Save the result
        savem(filer2, models{1});
end

function savem(filer2, models) %#ok<INUSD>
    save(filer2, 'models');
end
