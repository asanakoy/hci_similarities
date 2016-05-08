function [] = save_pairs(neg_max_sim, pos_min_sim, category_name, TEST_FRACTION, sim_file)
% Create and save pairs and labels
% 0 - negative pair (not similar)
% 1 - positive pair (similar)

if ~exist('category_name', 'var')
    category_name = 'long_jump';
end

if ~exist('sim_file', 'var')
    sim_file = load(sprintf('~/workspace/OlympicSports/sim/simMatrix_%s.mat', category_name));
end
if ~exist('TEST_FRACTION', 'var')
    TEST_FRACTION = 0.15;
end

[a_neg, b_neg, is_flipped_neg] = twostream_cnn.create_pairs(0.0001, neg_max_sim, category_name, sim_file.simMatrix, sim_file.flipval);
[a_pos, b_pos, is_flipped_pos] = twostream_cnn.create_pairs(pos_min_sim, 1e9, category_name, sim_file.simMatrix, sim_file.flipval);

fprintf('====\nNeg pairs: %d\nPos pairs: %d\n', length(a_neg), length(a_pos));

test_per_class = ceil(length(a_pos) * TEST_FRACTION);
train_neg = length(a_neg) - test_per_class;
train_pos = length(a_pos) - test_per_class;
fprintf('Test per class: %d\n', test_per_class);
fprintf('====\nTrain Neg: %d\nTrain Pos: %d\n', train_neg, train_pos);

phase = 'train';
a_train = [a_neg(1:train_neg); a_pos(1:train_pos)];
b_train = [b_neg(1:train_neg); b_pos(1:train_pos)];
is_flipped_train = [is_flipped_neg(1:train_neg);
                    is_flipped_pos(1:train_pos)];     
labels_train = [zeros(train_neg, 1, 'uint8'); ones(train_pos, 1, 'uint8')];
whos a_train
save_to_disk(a_train, b_train, is_flipped_train, labels_train, phase, category_name, neg_max_sim, pos_min_sim)


phase = 'test';
a = [a_neg(train_neg + 1:end); a_pos(train_pos + 1:end)];
b = [b_neg(train_neg + 1:end); b_pos(train_pos + 1:end)];
is_flipped = [is_flipped_neg(train_neg + 1:end);
                    is_flipped_pos(train_pos + 1:end)];
labels = [zeros(test_per_class, 1, 'uint8'); ones(test_per_class, 1, 'uint8')];
assert(all(size(a) == size(b)) && all(size(a) == size(is_flipped)));
whos a
save_to_disk(a, b, is_flipped, labels, phase, category_name, neg_max_sim, pos_min_sim)

end

function [] = save_to_disk(a, b, is_flipped, labels, phase, category_name, neg_max_sim, pos_min_sim)
    file_to_save = sprintf('~/workspace/OlympicSports/twostream_cnn/pairs_%s_%.2f_%.2f_%s.mat', ...
                category_name, neg_max_sim, pos_min_sim, phase);
fprintf('Saving on disk... %s\n', file_to_save);
save(file_to_save, '-v7.3', 'a', 'b', 'labels', 'is_flipped');
end
