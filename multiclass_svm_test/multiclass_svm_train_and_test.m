function [ model ] = multiclass_svm_train_and_test( train_data, test_data, kernel_type )
% Train multi-class SVM using one-vs-all approach and test it

LINEAR_KERNEL = 0;
RBF_KERNEL = 2;

num_classes = max(train_data.y);
n_test = length(test_data.y);

fprintf('Training one-vs-all SVMs\n');
model = cell(1, num_classes);
for k = 1:num_classes
    if kernel_type == LINEAR_KERNEL
        model{k} = svmtrain(double(train_data.y == k), train_data.X, '-c 1 -t 0 -b 1');
    elseif kernel_type == RBF_KERNEL
        model{k} = svmtrain(double(train_data.y == k), train_data.X, '-c 1 -g 0.2 -b 1'); % RBF
    else
        error('Unimplemented kernel');
    end
    
end

%# get probability estimates of test instances using each model
prob = zeros(n_test, num_classes);
for k = 1:num_classes
    [~,~,p] = svmpredict(double(test_data.y == k), test_data.X, model{k}, '-b 1');
    prob(:, k) = p(:, model{k}.Label == 1);    %# probability of class==k
end

%# predict the class with the highest probability
[~, pred] = max(prob, [], 2);
acc = sum(pred == test_data.y) / n_test    %# accuracy
% C = confusionmat(test_data.y, pred)           %# confusion matrix

end

