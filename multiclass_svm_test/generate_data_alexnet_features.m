function [ train_data, cv_data, test_data ] = generate_data_alexnet_features(settings, cliques_filepath, ...                                                  
                                                                     features_data_filepath, flipped_features_data_filepath )
%GENERATE_DATA_ALEXNET_FEATURES generate data using feature representation
%from CNN layer

assert(settings.train_fraction + settings.cv_fraction + settings.test_fraction == 1.0);

file = load(cliques_filepath);

fprintf('Reading features and flipped features file...\n');
dataset = load(features_data_filepath);
flipped_dataset = load(flipped_features_data_filepath);

train_data.X = [];
train_data.y = [];

cv_data.X = [];
cv_data.y = [];

test_data.X = [];
test_data.y = [];

offset = 0;

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
        features = get_feature_vector(frame_id, is_flipped, dataset, flipped_dataset);
        X = cat(1, X, features);
    end
    
    n_train = round(size(X, 1) * settings.train_fraction);
    n_cv = round(size(X, 1) * settings.cv_fraction);
    n_test = size(X, 1) - n_train - n_cv;
    
    train_data.X = cat(1, train_data.X, X(1:n_train, :));
    train_data.y = cat(1, train_data.y, repmat(i, n_train, 1));
    
    cv_data.X = cat(1, cv_data.X, X((n_train+1):(n_train + n_cv), :));
    cv_data.y = cat(1, cv_data.y, repmat(i, n_cv, 1));
    
    test_data.X = cat(1, test_data.X , X((n_train+n_cv+1):end, :));
    test_data.y = cat(1, test_data.y, repmat(i, n_test, 1));
end
fprintf('\n');

end

function [features] = get_feature_vector(frame_id, is_flipped, dataset, flipped_dataset)
    
    if is_flipped
        features = flipped_dataset.fc7(frame_id, :);
    else
        features = dataset.fc7(frame_id, :);
    end
    
end