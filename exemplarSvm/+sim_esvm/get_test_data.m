function [ positives, negatives ] = get_test_data( global_anchor_id, labels, data_info )
%GET_TEST_DATA For the given anchor frame.
%   Return: positives and negatives, where all ids are global dataset ids.

category_name = data_info.categoryNames{data_info.categoryLookupTable(global_anchor_id)};
category_offset = get_category_offset(category_name, data_info);

search_index = find(arrayfun(@(x) ...
                x.anchor + category_offset == global_anchor_id, ...
                labels, 'UniformOutput', true));
assert(length(search_index) == 1);

positives = labels(search_index).positives;
negatives = labels(search_index).negatives;

positives.ids = positives.ids + category_offset;
negatives.ids = negatives.ids + category_offset;

end

