function [category_offset] = get_category_offset(category_name, data_info)
% Get number of samples that preceeds the current category in the list of
% all sample ids.
% If category_offset = x, than it means that the sample with id (x + 1) is
% the first sample from the specified category.

    category_id = find(ismember(data_info.categoryNames, category_name));
    assert(~isempty(category_id), 'Incorrect category_name!');
    category_offset = 0;
    for i = 1:length(data_info.categoryLookupTable)
        if (data_info.categoryLookupTable(i) == category_id)
            category_offset = i - 1;
            break;
        end
    end
    
end

