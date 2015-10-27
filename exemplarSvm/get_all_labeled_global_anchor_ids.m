function [ anchor_ids ] = get_all_labeled_global_anchor_ids( labels_dir_path )
%Returns all global anchor frame ids, for which we have labeled data.
%labels_dir_path - dir with labels *.mat files

anchor_ids = [];

file_list = getFilesInDir(labels_dir_path, '.*\.mat');

fprintf('Getting all anchor ids...\n');
for i = 1:length(file_list)
    fprintf('Labels file %d\n', i);
    file = load(fullfile(dir_path, file_list{i}));
    
    anchor_ids = [anchor_ids (cell2mat({file.labels.anchor}) + file.category_offset)];
    
end

end

