function [category_offset] = get_category_offset(category_name, data_info)

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

