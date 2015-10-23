% DEMO: Training Exemplar-SVMs from synthetic data
% This function can generate a nice HTML page by calling: 
% publish('esvm_demo_train_synthetic.m','html')
%
% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved. 
%
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm
%
% In this demo, I create a random dataset of circular patterns on a
% random background of noise with extra noise sprinkled on top.
% Because the circles are synthetically generated, we have access
% to ground-truth locations of those circles and these are used to
% define the positive bounding boxes.  The learned Exemplar-SVMs
% plus the calibration M-matrix are first learned, then applied to
% a testing set of images along with the top detections.
% function [models,M] = sim_esvm_train

ESVM_LIB_PATH = '/net/hciserver03/storage/asanakoy/workspace/exemplarsvm';
addpath(genpath(ESVM_LIB_PATH))

% dataset_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports';
ataset_path = '/net/hciserver03/storage/asanakoy/workspace_copy_22.10.15/OlympicSports';


if ~exist('dataInfo', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

%% Create a synthetic dataset of circles on a random background
% The resulting images are also corrupted with noise to provide a
% more difficult case.  Negative images are random noise images
% without any circular pattern.
% Npos = 100; Nneg = 50; [pos_set,neg_set] = esvm_generate_dataset(Npos,Nneg);
anchor_ids = [80031];
models_name = 'long_jump'; % category name

[pos_set, neg_set] = sim_esvm_create_train_dataset(anchor_ids, models_name, dataset_path, data_info);



%% Set exemplar-initialization parameters
params = esvm_get_default_params;
params.detect_max_scale = 1.0;
params.detect_min_scale = 1.0;
params.init_params.detect_max_scale = params.detect_max_scale;
params.init_params.detect_min_scale = params.detect_min_scale;
%Levels-per-octave defines how many levels between 2x sizes in pyramid
%(denser pyramids will have more windows and thus be slower for
%detection/training)
params.detect_levels_per_octave = 1;
%How much we pad the pyramid (to let detections fall outside the image)
params.detect_pyramid_padding = 2; % size of the window shifting
%Maximum #windows per exemplar (per image) to keep. I.e. how many
%detections are allowed inside one image (flipped and non-flipped are
%counted as different images;
%if val == 2 then 2 detections are allowed for flipped and 2 for non-flipped: 4 total)
params.detect_max_windows_per_exemplar = 1;

params.detect_exemplar_nms_os_threshold = 1.0; % non-maximum supression on

%Default detection threshold (negative margin makes most sense for
%SVM-trained detectors).  Only keep detections for detection/training
%that fall above this threshold.
params.detect_keep_threshold = -1.5;

params.init_params.sbin = 8; % HOG cell size
params.init_params.MAXDIM = 6; % DOES not affect, as we have only one scale = 1.0
params.model_type = 'exemplar';

%enable display so that nice visualizations pop up during learning
params.dataset_params.display = 1;

%if localdir is not set, we do not dump files
params.dataset_params.localdir = '';%'/net/hciserver03/storage/asanakoy/workspace/OlympicSports_esvm_localdir';

%if enabled, we dump learning images into results directory
params.dump_images = 0;

%%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 10;
stream_params.must_have_seg = 0;
stream_params.must_have_seg_string = '';
stream_params.model_type = 'exemplar'; %must be scene or exemplar
%assign pos_set as variable, because we need it for visualization
stream_params.pos_set = pos_set;
stream_params.cls = models_name;

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
initial_models = esvm_initialize_exemplars(e_stream_set, params, ...
                                           models_name);


%% Set exemplar-svm training parameters
train_params = params;

%The maximum number of negatives to keep in the cache while training.
train_params.train_max_negatives_in_cache = 2000;

%Maximum global number of mining iterations, where an iteration is
%when queue fills with max_windows_before_svm detections or
%max_windows_before_svm images have been processed
train_params.train_max_mine_iterations = 100;

%Maximum TOTAL number of image accesses from the mining queue
train_params.train_max_mined_images = 10000;

%Maximum number of negatives to mine before SVM kicks in (this
%defines one iteration)
train_params.train_max_windows_per_iteration = 1000;

%Maximum number of violating images before SVM is trained with current cache
train_params.train_max_images_per_iteration = 400;

%% Perform Exemplar-SVM training
% Because display is turned on, we will show the result of each
% exemplar's training iteration.   Each iteration shows a
% diagnostic first column then the remaining rows are the top
% negative support vectors used to define the exemplar's decision
% boundary.  The diagnostic row shows: exemplar, w's positive
% part, w's negative part, and four mean support vector images,
% where the means are computed with the first 1:N/4, 1:N/2, .. ,
% 1:N support vectors.
[models] = esvm_train_exemplars(initial_models, ...
                                neg_set, train_params);
M = [];

fprintf('Press Enter to start testing');
pause;

%% Define test-set
% test_images_ids = [3605 3910 10000 38000 31000 3610];
positive_category_id = find(ismember(data_info.categoryNames, models_name));
test_images_ids = find(data_info.categoryLookupTable == positive_category_id);
% TODO filter self

test_set = sim_esvm_create_dataset(test_images_ids, dataset_path, data_info);
test_params = params;
% test_params.detect_exemplar_nms_os_threshold = 0.1;
test_set_name = 'testset';

%% Apply on test set
tic;
test_grid = esvm_detect_imageset(test_set, models, test_params, test_set_name);

%% Apply calibration matrix to test-set results
test_struct = esvm_pool_exemplar_dets(test_grid, models, M, test_params);
toc

%% Show top detections
% Each resulting figure will show the source exemplar/weights (left
% column)from the top detection as well as the detection box in the
% resulting image (top right) and the exemplar inpainting (bottom
% right).
maxk = 100;

allbbs = esvm_show_top_dets(test_struct, test_grid, test_set, models, ...
                       params, maxk, test_set_name);