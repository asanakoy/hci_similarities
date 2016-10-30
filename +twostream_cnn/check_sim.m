function [] = check_sim(category_name)

dataset_path = '/export/home/asanakoy/workspace/OlympicSports/';

if ~exist('simMatrix', 'var')
    [ simMatrix, ~ ] = twostream_cnn.load_sim_matrix(dataset_path, category_name);
end
fprintf('Num samples: %d\n', length(simMatrix));
simMatrix = twostream_cnn.prepare_sim_matrix(dataset_path, category_name, simMatrix);

scores = zeros(size(simMatrix));
for i = 1:length(simMatrix)
    simMatrix(i,i) = 0;
    scores(i, :) = sort(simMatrix(i, :));
end

figure;
scores = scores(:, end:-1:1);
row_mean = mean(scores, 1);
plot(row_mean); title(['mean ', category_name]);

% row_std = std(scores, 1, 1);
% figure;
% plot(row_std); title(['std ', category_name]);
% 
% figure;
% k = 1000;
% errorbar(1:10:k, row_mean(1:10:k), row_std(1:10:k))
% title(category_name);

figure;
non_zero_scores = scores(scores > 0 );
hist(non_zero_scores, round(max(non_zero_scores)));
title(category_name);

% x = x(:);
% y = y(:);

% figure;
% subplot(1,2,1);
% f = fit(x,y,'gauss2')
% plot(f, x,y);
% title(category_name);


end