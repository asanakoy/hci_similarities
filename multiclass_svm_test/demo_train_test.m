
%% Raw data, probabilities
params_format = '-c %e -t 0 -g %e -b 0 -w1 12 -q';
train_and_test(params_format, train_data, cv_data, test_data, 100);

params_format = '-c %e -t 2 -g 0.1 -b 0 -w1 12 -q';
train_and_test(params_format, train_data, cv_data, test_data, 10);


%% Z-scores, values
% data = cat(1, train_data.X, cv_data.X, test_data.X);
% data = zscore(data);

% z_train_data = train_data;
% z_cv_data = cv_data;
% z_test_data = test_data;
% 
% train_end = size(train_data.X, 1);
% cv_end = size(train_data.X, 1) + size(cv_data.X, 1);
% z_train_data.X = data(1:train_end, :);
% z_cv_data.X = data((train_end + 1):cv_end, :);
% z_test_data.X = data((cv_end + 1):end, :);
% 
% params_format = '-c %e -t 0 -g %e -b 0 -w1 12 -q';
% train_and_test(params_format, z_train_data, z_cv_data, z_test_data);

% params_format = '-c %e -t 2 -g %e -b 0 -w1 12 -q';
% train_and_test(params_format, z_train_data, z_cv_data, z_test_data, 10);