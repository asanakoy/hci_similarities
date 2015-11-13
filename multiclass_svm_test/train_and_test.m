function [ models, accuracy ] = train_and_test( params_fromat, train_data, cv_data, test_data, number_of_tune_points )
%TRAIN_AND_TEST Summary of this function goes here
%   Detailed explanation goes here

if ~exist('number_of_tune_points', 'var')
    number_of_tune_points = 50;
end

NUM_CLASSES = length(unique(train_data.y));
assert(NUM_CLASSES == 13);

if strfind(params_fromat, '-t 0')
    fprintf('Linear kernel\n');
elseif strfind(params_fromat, '-t 2')
    fprintf('RBF kernel\n');
else
    Error('Unknown kernel\n');
end
[models, tuned_params] = tune_params(params_fromat, train_data, cv_data, number_of_tune_points);

train_with_probabilities = any(strfind(params_fromat, '-b 1'));
accuracy = test_svm(models, test_data, NUM_CLASSES, train_with_probabilities);

end

