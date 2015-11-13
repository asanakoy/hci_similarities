function [ accuracy ] = test_svm( models,  test_data, num_classes, trained_with_probabilities)
%TEST_SVM Summary of this function goes here
%   Detailed explanation goes here

assert(length(unique(test_data.y)) == num_classes);
n_test = length(test_data.y);

params = '';
if trained_with_probabilities
    params = '-b 1';
end
prob = zeros(n_test, num_classes);
% get probability estimates of test instances using each model

for k = 1:num_classes
    [labels,~,p] = svmpredict(double(test_data.y == k), test_data.X, models{k}, [params ' -q']);
    if trained_with_probabilities
        prob(:, k) = p(:, models{k}.Label == 1);    % probability of class==k
    else
        if (models{k}.Label(1) == 0)
            p = -p;
        end
        prob(:, k) = p(:);
         
    end
    
%     fprintf('pos val > 0 ? %d\n', sum(labels == (prob(:,k)>0)) > sum(labels == (prob(:,k)<0)) );
end

% predict the class with the highest probability
[~, pred] = max(prob, [], 2);
accuracy = sum(pred == test_data.y) / n_test;  
fprintf('Accuracy = %f\n', accuracy);
% C = confusionmat(test_data.y, pred)           % confusion matrix

end

