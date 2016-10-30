function [ a, b, is_flipped ] = create_pairs(min_sim, max_sim, category_name, simMatrix, flipvals)
%SHOW_PAIRS Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/export/home/asanakoy/workspace/OlympicSports/';

simMatrix = twostream_cnn.prepare_sim_matrix(dataset_path, category_name, simMatrix);

[a, b] = find(simMatrix >= min_sim & simMatrix <= max_sim);
is_flipped = zeros(length(a), 1);
for i = 1:length(a)
    is_flipped(i) = flipvals(a(i), b(i));
end
fprintf('Num pairs: %d\n', length(a));

end

