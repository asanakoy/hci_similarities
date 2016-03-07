function [ params ] = get_default_params
%GET_DEFAULT_PARAMS Returns default params for ESVM

%% Set exemplar-initialization parameters
params = esvm_get_default_params;
params.detect_max_scale = 1.0;
params.detect_min_scale = 1.0;
params.detect_add_flip = 1;
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
params.detect_keep_threshold = -1.2;

params.features_type = 'HOG-like'; % ['FeatureVector' | 'HOG-like']

%Should we use: W_pos = n_pos / N, W_neg = n_neg / N ?
params.auto_weight_svm_classes = 0;

params.init_params.features_type = params.features_type;
params.init_params.features = @esvm_features;

params.init_params.sbin = 8; % HOG cell size
params.init_params.MAXDIM = 28; % DOES not affect, as we have only one scale = 1.0
params.model_type = 'exemplar';

%enable display so that nice visualizations pop up during learning
params.dataset_params.display = 0;

%if localdir is not set, we do not dump files
params.dataset_params.localdir = '';

%if enabled, we dump learning images into results directory
params.dump_images = 0;

end

