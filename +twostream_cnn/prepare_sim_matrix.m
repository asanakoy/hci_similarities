function [ simMatrix ] = prepare_sim_matrix(dataset_path, category_name, simMatrix )
% Eliminate all similarities from the same sequence, eliminate
% under-diagonal elements.
simMatrix = triu(simMatrix);

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
category_offset = get_category_offset(category_name, data_info);

[first_sequence_index, ~ ] = getSequenceIndex(category_offset + 1,  data_info.sequenceLookupTable);

cur_seq_index = first_sequence_index;
seq = data_info.sequenceLookupTable(cur_seq_index);
seq.begin = seq.begin - category_offset;
seq.end = seq.end - category_offset;

for i = 1:length(simMatrix)
%     fprintf('%d\n', i);
    if i > seq.end
        cur_seq_index = cur_seq_index + 1;
        seq = data_info.sequenceLookupTable(cur_seq_index);
        seq.begin = seq.begin - category_offset;
        seq.end = seq.end - category_offset;
    end
    simMatrix(i, seq.begin: seq.end) = 0;
end

end

