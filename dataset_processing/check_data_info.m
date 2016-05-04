function [] = check_data_info( data_info, crops_path)
%CHECH_DATA_INFO Summary of this function goes here
%   Detailed explanation goes here
fprintf('Checking data_info on validity...\n');
categoryNames = getNonEmptySubdirs(crops_path);

for i = 1:length(categoryNames)
    assert(strcmp(data_info.categoryNames{i}, categoryNames{i}) == 1);
    cat_name = categoryNames{i};
    
    [ret_code, out] = system(sprintf('find %s -iname \"*.jpg\" -type f | wc -l', ...
                      fullfile(crops_path, cat_name)));
    assert(ret_code == 0);
    cat_size = str2num(out);
    
    assert(cat_size == get_category_size(cat_name, data_info));
end
fprintf('OK\n');
end

