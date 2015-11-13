function [ models, accuracy ] = multiclass_svm_train_and_test( params, train_data, cv_data)
% Train multi-class SVM using one-vs-all approach and test it
% params = '-c 1 -t 0 -b 1'

trained_with_probabilities = any(strfind(params_fromat, '-b 1'));

num_classes = length(unique(train_data.y));

fprintf('Training one-vs-all SVMs\n');
models = cell(1, num_classes);
for k = 1:num_classes
        models{k} = svmtrain(double(train_data.y == k), train_data.X, params);  
end

accuracy = test_svm(models, cv_data, num_classes, trained_with_probabilities); 

end

