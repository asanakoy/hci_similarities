function [ train_data, test_data ] = generate_data( settings, cliques_filepath )
%GENERATE_DATA Summary of this function goes here
%   Detailed explanation goes here
validateattributes(settings, {'MulticlassSvmSettings'}, {'scalar'});

file = load(cliques_filepath);

fprintf('Reading global crops info file...\n');
CROPS_GLOBAL_INFO = load(fullfile(DatasetStructure.getDataDirPath(settings.dataset_path), 'crops_global_info.mat'));
fprintf('Reading dataset info file...\n');
DATA_INFO = load(DatasetStructure.getDataInfoPath(settings.dataset_path));

train_data.X = [];
train_data.y = [];

test_data.X = [];
test_data.y = [];

offset = get_category_offset(settings.category_name, DATA_INFO);

fprintf('Loading esvm models...\n');
basis_models = load_basis_esvm_models(settings.basis_models_handles, settings.get_esvm_models_path());


str = sprintf('%04d/%04d', 0, length(file.cliques{1}));
str_width = length(str);
clean_symbols = repmat('\b', 1, str_width);
fprintf('Calculating scores for clique: %s', str);
for i = 1:length(file.cliques{1})
    X = [];
    fprintf(clean_symbols);
    fprintf('%04d/%04d', i, length(file.cliques{1}));
    for j = 1:length(file.cliques{1}{i})
        frame_id = file.cliques{1}{i}(j) + offset;
        is_flipped = file.flips{1}{i}(j);
        features = get_feature_vector(frame_id, is_flipped, basis_models, CROPS_GLOBAL_INFO, settings.crops_path);
        X = cat(1, X, features);
    end
    
    n_train = round(size(X, 1) * settings.train_fraction);
    n_test = size(X, 1) - n_train;
    
    train_data.X = cat(1, train_data.X, X(1:n_train, :));
    train_data.y = cat(1, train_data.y, repmat(i, n_train, 1));
    
    test_data.X = cat(1, test_data.X , X((n_train+1):end, :));
    test_data.y = cat(1, test_data.y, repmat(i, n_test, 1));
end
fprintf('\n');

end

function [features] = get_feature_vector(frame_id, is_flipped, basis_models, crops_global_info, crops_path)
    
    im = imread(fullfile(crops_path, crops_global_info.crops(frame_id).img_relative_path), 'png');
    if is_flipped
        im = fliplr(im);
    end
    
    features = zeros(1, length(basis_models));
    for i = 1:length(basis_models)
        features(i) = sim_esvm_get_score(im, basis_models{i});
    end
end

