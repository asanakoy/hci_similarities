function [ category_size ] = get_category_size( category_name, data_info )
%GET_CATEGORY_SIZE Get numer of samples in the specified category.

category_id = find(ismember(data_info.categoryNames, category_name));
category_size = sum(data_info.categoryLookupTable == category_id);
    
end

