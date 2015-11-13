

params_fromat = '-c %e -t 0 -g %e -b 1 -w1 12 -q';
[models, tuned_params] = tune_params(params_fromat, train_data, cv_data);

multiclass_svm_train_and_test( '-c 1 -t 0 -g 0.2 -b 1 -w1 12', train_with_probabilities, train_data, test_data);
pause;
multiclass_svm_train_and_test( '-c 1 -t 0 -b 1 -w1 12', train_with_probabilities, train_data, test_data_aug);
