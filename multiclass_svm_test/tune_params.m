function [models, tuned_params] = tune_params(params_format, train_data, cv_data, number_of_points)

if ~exist('params_format', 'var')
    params_format = '-c %e -t 0 -g %e -b 1 -w1 12 -q';
end

if ~exist('number_of_points', 'var')
    number_of_points = 50;
end

train_with_probabilities = any(strfind(params_format, '-b 1'));
predict_params = sprintf('-b %d -q', train_with_probabilities);

if strfind(params_format, '-t 2')
    if strfind(params_format, '-g %e')   
        gamma = logspace(-9, 9, number_of_points);
    else
        res = regexp(params_format, '-g (?<gamma>\d+\.\d+)', 'names');
        if ~isempty(res)
            gamma = str2num(res.gamma);
        else
            error('Specify the gamma!\n');
        end
    end
else
    gamma = 0;
end

if strfind(params_format, '-c %e')   
        C = logspace(-9, 9, number_of_points);
    else
        res = regexp(params_format, '-c (?<c_param>\d+\.\d+)', 'names');
        if ~isempty(res)
            C = str2num(res.c_param);
        else
            error('Specify the C!\n');
        end
end

scores = zeros(1, length(C) * length(gamma));
num_classes = length(unique(train_data.y));
assert(min(train_data.y) == 1);
assert(max(train_data.y) == num_classes);
w_pos = 12.0;

models = cell(1, num_classes);
tuned_params = repmat(struct('C', 1, 'gamma', 1), [num_classes, 1]);
max_score = zeros(num_classes, 1);


format_str = 'class %02d --param C: %02d/%02d\n';
str = sprintf(format_str, 0, 0, length(C));
clean_symbols = repmat('\b', 1, length(str));
    
fprintf(format_str, 0, 0, length(C));
for k = 1:num_classes
    for i = 1:length(C)
        fprintf(clean_symbols);
        fprintf(format_str, k, i, length(C));
        for j = 1:length(gamma)

            models{k} = svmtrain(double(train_data.y == k), train_data.X, sprintf(params_format, C(i), gamma(j)));  
            predicted_label = svmpredict(double(cv_data.y == k), cv_data.X, models{k}, predict_params);
            score = get_score(predicted_label, cv_data.y == k, w_pos);
%             fprintf('Score = %f%%\n', score * 100.0);
            
            if score > max_score(k)
                max_score(k) = score;
                tuned_params(k).C = C(i);
                tuned_params(k).gamma = gamma(j);
            end
            
        end
    end
    
    models{k} = svmtrain(double(train_data.y == k), train_data.X, sprintf(params_format,  tuned_params(k).C, tuned_params(k).gamma));  
    
end

fprintf('Max scores on CV dataset:  \n');
max_score

end

function score = get_score(predicted_labels, ground_truth_labels, w_pos)
    pos_indices = find(ground_truth_labels == 1);
    neg_indices = find(ground_truth_labels == 0);
    
    
    precision = sum(predicted_labels(pos_indices) == 1) / sum(predicted_labels == 1);
    recall = sum(predicted_labels(pos_indices) == 1) / length(pos_indices);
    
    score = 2 * precision * recall / (precision + recall);
    
%     score = (sum(predicted_labels(pos_indices) == 1) * w_pos + sum(predicted_labels(neg_indices) == 0)) ...
%                                             / (length(pos_indices) * w_pos + length(neg_indices));
    
end