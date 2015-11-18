
setup()


% params_format = '-c %e -t 0 -g %e -b 0 -w1 12 -q';
% [model1, acc(1)] = train_and_test(params_format, train_data_aug, cv_data_aug, test_data_aug, 10);

fprintf('learning Linear 50')
params_format = '-c %e -t 0 -g %e -b 0 -w1 12 -q'; % was C = 1.0
[model_lin_c_tune50, accuracy] = train_and_test(params_format, train_data_aug, cv_data_aug, test_data_aug, 50);
% 
% fprintf('learning RBF 10')
% params_format = '-c %e -t 2 -g %e -b 0 -w1 12 -q';
% [model3, acc(3)] = train_and_test(params_format, train_data_aug, cv_data_aug, test_data_aug, 10);
% 
% aug_models = [model1, model2, model3];

save('~/workspace/OlympicSports/multiclass_svm_test/models_aug_linear_c_50-tune.mat', '-v7.3', 'model_lin_c_tune50', 'accuracy');
