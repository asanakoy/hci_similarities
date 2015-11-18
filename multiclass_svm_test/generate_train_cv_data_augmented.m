function [train_data, cv_data] = generate_train_cv_data_augmented(settings, data_filepath)
%GENERATE_TRAIN_CV_DATA_AUGMENTED Summary of this function goes here
%   Detailed explanation goes here

train_fraction = settings.train_fraction / (settings.train_fraction + settings.cv_fraction);
cv_fraction =  settings.cv_fraction / (settings.train_fraction + settings.cv_fraction);
 
assert(train_fraction + cv_fraction == 1.0);

data = generate_data_augmented( settings, data_filepath);

train_data.X = [];
train_data.y = [];

cv_data.X = [];
cv_data.y = [];

num_classes = length(unique(data.y));
assert(min(data.y) == 1);
assert(max(data.y) == num_classes);

for c = 1:num_classes

    indices = find(ismember(data.y, c));
    perm = randperm(length(indices));
    
    n_train = round(length(indices) * train_fraction);
    
    train_indices =  indices( perm(1:n_train) );
    train_data.X = cat(1, train_data.X, data.X(train_indices, :));
    train_data.y = cat(1, train_data.y, data.y(train_indices));
    
    cv_indices = indices( perm((n_train+1):end) );
    cv_data.X = cat(1, cv_data.X, data.X(cv_indices, :));
    cv_data.y = cat(1, cv_data.y, data.y(cv_indices));
    
end


end



