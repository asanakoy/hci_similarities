function [ a, b, is_flipped ] = create_pairs(min_sim, max_sim, category_name, simMatrix, flipvals)
%SHOW_PAIRS Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/export/home/asanakoy/workspace/OlympicSports/';

simMatrix = triu(simMatrix);

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
category_offset = get_category_offset(category_name, data_info);

[first_sequence_index, ~ ] = getSequenceIndex(category_offset + 1,  data_info.sequenceLookupTable);

cur_seq_index = first_sequence_index;
seq = data_info.sequenceLookupTable(cur_seq_index);
seq.begin = seq.begin - category_offset;
seq.end = seq.end - category_offset;

for i = 1:length(simMatrix)
    fprintf('%d\n', i);
    if i > seq.end
        cur_seq_index = cur_seq_index + 1;
        seq = data_info.sequenceLookupTable(cur_seq_index);
        seq.begin = seq.begin - category_offset;
        seq.end = seq.end - category_offset;
    end
    simMatrix(i, seq.begin: seq.end) = 0;
end

[a, b] = find(simMatrix >= min_sim & simMatrix <= max_sim);
is_flipped = zeros(length(a), 1);
for i = 1:length(a)
    is_flipped(i) = flipvals(a(i), b(i));
end
fprintf('Num pairs: %d\n', length(a));

end

