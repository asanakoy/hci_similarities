
% Raw data, probabilities
params_format = '-c %e -t 0 -g %e -b 0 -w1 12 -q';
train_and_test(params_format, train_data_cnn, cv_data_cnn, test_data_cnn, 50);


params_format = '-c %e -t 2 -g %e -b 0 -w1 12 -q';
train_and_test(params_format, train_data_cnn, cv_data_cnn, test_data_cnn, 10);

