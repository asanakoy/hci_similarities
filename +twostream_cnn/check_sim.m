category_name = 'long_jump';
sim_path = sprintf('~/workspace/OlympicSports/sim/simMatrix_%s.mat', category_name);

if ~exist('simMatrix', 'var')
    load(sim_path);
end

scores = zeros(size(simMatrix));
for i = 1:length(simMatrix)
    simMatrix(i,i) = 0;
    scores(i, :) = sort(simMatrix(i, :));
end

scores = scores(:, end:-1:1);
row_mean = mean(scores, 1);
plot(row_mean);

row_std = std(scores, 1, 1);
figure;
plot(row_std); title('std');

figure;
k = 100;
errorbar(1:k, row_mean(1:k), row_std(1:k))

