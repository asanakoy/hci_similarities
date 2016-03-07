% Train Exemplar-SVMs
% 
% If you want to train useing CNN_FEATURES, you need to load features in
% memory before running training.
%
% Copyright (C) 2015-16 by Artsiom Sanakoyeu
% All rights reserved. 
function [models, M] = train(anchor_id, anchor_flipval, output_dir, ...
                                     esvm_train_params, initial_models)

narginchk(4, 5);
assert(length(anchor_id) == 1 && length(anchor_flipval) == 1);
sim_esvm.check_esvm_train_params(esvm_train_params);
assert(isfield(esvm_train_params, 'train_svm_c'));
assert(isfield(esvm_train_params, 'positive_class_svm_weight'));
assert(isfield(esvm_train_params, 'auto_weight_svm_classes'));

data_info = esvm_train_params.create_data_params.data_info;

category_name = data_info.categoryNames{data_info.categoryLookupTable(anchor_id)};
esvm_train_params.create_data_params.positive_category_name = category_name;
esvm_train_params.create_data_params.positive_category_offset = get_category_offset(category_name, data_info);


fprintf('->sim_esvm.train ...\n')
%% Create a synthetic dataset of circles on a random background
% The resulting images are also corrupted with noise to provide a
% more difficult case.  Negative images are random noise images
% without any circular pattern.
% Npos = 100; Nneg = 50; [pos_set,neg_set] = esvm_generate_dataset(Npos,Nneg);
start_train = tic;
assert(all(anchor_flipval == 0), 'Anchor flipval is not zero!');

model_name = sprintf('%06d', anchor_id); % category name
if anchor_flipval
    model_name = [model_name '_flipped'];
end


if strcmp(esvm_train_params.training_type, 'pos_svm')
    labels = esvm_train_params.labeled_data.labels;
    [positives, ~] = sim_esvm.get_test_data(anchor_id, labels, data_info);
    
    positive_ids = [anchor_id, positives.ids];
    positive_flipvals = [anchor_flipval, positives.flipval];
    
elseif strcmp(esvm_train_params.training_type, 'clique_svm')
    positives = sim_esvm.get_positive_clique(anchor_id, esvm_train_params.create_data_params);
    
    positive_ids = [anchor_id, positives.ids];
    positive_flipvals = [anchor_flipval, positives.flipval];
    
    num_positives_before = length(positive_ids);
    
    [~, perm, ~] = unique(positive_ids);
    positive_ids = positive_ids(perm);
    positive_flipvals = positive_flipvals(perm);
    
    assert(num_positives_before <= length(positive_ids) + 1, ...
        'We have clique with non-unique values! anchor_local_id: %d', ...
        anchor_id - esvm_train_params.create_data_params.positive_category_offset);
    
    if num_positives_before == length(positive_ids)
        fprintf('NOTE: Anchor was not in clique!\n');
    end
    
else
    positive_ids = anchor_id;
    positive_flipvals = anchor_flipval;
end

[pos_set, neg_set] = sim_esvm.create_train_dataset(positive_ids, positive_flipvals, esvm_train_params.create_data_params);


%% Set exemplar-initialization parameters
params = sim_esvm.get_default_params;
%if localdir is not set, we do not dump files
params.dataset_params.localdir = output_dir;

%================ Set params passed from outside =====================
params = update_esvm_params(params, esvm_train_params);
%======================================================================

%%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 10;
stream_params.must_have_seg = 0;
stream_params.must_have_seg_string = '';
stream_params.model_type = 'exemplar'; %must be scene or exemplar
%assign pos_set as variable, because we need it for visualization
if strcmp(esvm_train_params.training_type, 'clique_svm') || strcmp(esvm_train_params.training_type, 'pos_svm')
    stream_params.pos_set = sim_esvm.create_dataset(anchor_id, esvm_train_params.create_data_params, 0) ;
elseif strcmp(esvm_train_params.training_type, 'esvm')
    stream_params.pos_set = pos_set;
    assert(length(pos_set) == 1);
else
    assert(false, 'Unsopported training_type: %s', esvm_train_params.training_type);
end
stream_params.cls = category_name;

%% Get the positive stream
e_stream_set = esvm_get_pascal_stream(stream_params, ...
                                      params.dataset_params);

% % break it up into a set of held out negatives, and the ones used
% % for mining
% val_neg_set = neg_set((Nneg/2+1):end);
% neg_set = neg_set(1:((Nneg/2)));

%% Initialize Exemplars
% Each exemplar will have a figure, where on the first image is
% the exemplar's image, along with the exemplar bounding box and
% HOG grid overlayed.  The second image shows the HOG mask along
% with its offset to the ground-truth bounding box.  The third
% image shows the initial HOG features used to define the exemplar.
if (~exist('initial_models', 'var'))
    initial_models = esvm_initialize_exemplars(e_stream_set, params, ...
                                           [model_name]);
else
    fprintf('Using pre-trained model');
end

if strcmp(esvm_train_params.training_type, 'clique_svm') || strcmp(esvm_train_params.training_type, 'pos_svm')
    assert(length(initial_models) == 1);
    initial_models{1}.pos_train_set = pos_set;
    initial_models{1}.neg_train_set = neg_set;
elseif strcmp(esvm_train_params.training_type, 'esvm')
    assert(length(initial_models) == 1);
    assert(length(pos_set) == 1);
    initial_models{1}.pos_train_set = pos_set;
    assert(initial_models{1}.frame_id == pos_set{1}.I.id);
    initial_models{1}.neg_train_set = neg_set;

elseif strcmp(esvm_train_params.training_type, 'esvm_positive_clique_embedding')
    assert(false, 'Not implemented');
    % TODO: check
    for i = lenght(initial_models)
        initial_models{i}.pos_train_set = pos_set{i};
        assert(initial_models{i}.frame_id == pos_set{i}.I.id);
        initial_models{i}.neg_train_set = neg_set;
    end
else
    assert(false, 'Unknown training_type: %s', esvm_train_params.training_type);
end
    
    
%% Set exemplar-svm training parameters
train_params = params;

%The maximum number of negatives to keep in the cache while training.
train_params.train_max_negatives_in_cache = 2500;

%Maximum global number of mining iterations, where an iteration is
%when queue fills with max_windows_before_svm detections or
%max_windows_before_svm images have been processed
train_params.train_max_mine_iterations = 100;

%Maximum TOTAL number of image accesses from the mining queue
train_params.train_max_mined_images = data_info.totalNumberOfVectors;%2500;

%Maximum number of negatives to mine before SVM kicks in (this
%defines one iteration)
train_params.train_max_windows_per_iteration = 2000;

%Maximum number of violating images before SVM is trained with current cache
train_params.train_max_images_per_iteration = 1000;

%% Perform Exemplar-SVM training
% Because display is turned on, we will show the result of each
% exemplar's training iteration.   Each iteration shows a
% diagnostic first column then the remaining rows are the top
% negative support vectors used to define the exemplar's decision
% boundary.  The diagnostic row shows: exemplar, w's positive
% part, w's negative part, and four mean support vector images,
% where the means are computed with the first 1:N/4, 1:N/2, .. ,
% 1:N support vectors.
if esvm_train_params.use_negative_mining == 0
    
    [models] = esvm_train_exemplars(initial_models, train_params);
    
else
    assert(strcmp(esvm_train_params.training_type, 'esvm') ...
        || strcmp(esvm_train_params.training_type, 'pos_svm') ...
        || strcmp(esvm_train_params.training_type, 'clique_svm'), ...
        'Negatives mining is unsupported for training_type: %s', esvm_train_params.training_type);
    
    [models] = esvm_train_exemplars_with_mining(initial_models, ...
                                    neg_set, train_params);
end

if esvm_train_params.remove_top_hard_negatives_fraction > 0.0
    assert(esvm_train_params.use_negative_mining == 1);
    models = remove_top_hardest_negatives(models, neg_set, esvm_train_params);
end
                            
fprintf('Elapsed time fot ESVM training: %.2f seconds\n', toc(start_train));

if esvm_train_params.should_run_test
    assert(~strcmp(params.features_type, 'FeatureVector'), 'Not implemented for features_type: FeatureVector');
    
    fprintf('Press Enter to start testing');
%     pause;
    
    %% Define test-set
    % test_images_ids = [3605 3910 10000 38000 31000 3610];
    positive_category_id = find(ismember(data_info.categoryNames, category_name));
    test_images_ids = find(data_info.categoryLookupTable == positive_category_id);
    test_images_ids = test_images_ids(1:1000);
    % TODO filter self

    test_set = sim_esvm.create_dataset(test_images_ids, ...
        false(size(test_images_ids)), esvm_train_params.create_data_params);
    test_params = params;
    % test_params.detect_exemplar_nms_os_threshold = 0.1;
    test_set_name = 'testset';

    %% Apply on test set
    start_test = tic;
    test_grid = esvm_detect_imageset(test_set, models, test_params, test_set_name);

    %% Apply calibration matrix to test-set results
    M = [];
    test_struct = esvm_pool_exemplar_dets(test_grid, models, M, test_params);
    fprintf('Elapsed time fot ESVM testing: %.2f seconds\n', toc(start_test));

    %% Show top detections
    % Each resulting figure will show the source exemplar/weights (left
    % column)from the top detection as well as the detection box in the
    % resulting image (top right) and the exemplar inpainting (bottom
    % right).
    maxk = 100;

    %allbbs = esvm_show_top_dets(test_struct, test_grid, test_set, models, ...
    %                       params, maxk, test_set_name);
end

end
