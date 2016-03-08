function [ anchor_ids, flipvals ] = get_all_labeled_global_anchor_ids( labels_filepath )
%Returns all global anchor frame ids, for which we have labeled data.
%labels_dir_path - dir with labels *.mat files

fprintf('Getting all anchor ids...\n');
file = load(labels_filepath);
anchor_ids = [];
anchor_ids = [anchor_ids (cell2mat({file.labels.anchor}) + file.category_offset)];
    
flipvals = false(size(anchor_ids));

end

