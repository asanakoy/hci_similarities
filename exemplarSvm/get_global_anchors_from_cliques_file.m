function [ anchor_ids, anchor_flipvals ] = get_global_anchors_from_cliques_file( data_info, category_name, filepath, cliques_ids )
%GET_ANCHORS_FROM_CLIQUES_FILE Get gloabl anchor ids from file, containing cliques
% File consists of cliques of size 2
% Consider only cliques with ids from cliques_ids, take 1 point from each
% clique randomly.

file = load(filepath);

anchor_ids = [];
anchor_flipvals = false([0, 0]);
category_offset = get_category_offset(category_name, data_info);

if ~exist(cliques_ids, 'var')
    cliques_ids = 1:length(file.cliques{1});
end

for i = 1:length(cliques_ids)
    assert(clique_ids(i) <= length(file.cliques{1}), 'incorrect clique id: %d\n', i);
    
    anchor_ids = [anchor_ids (file.cliques{1}{clique_ids(i)} + category_offset)];
    anchor_flipvals = [anchor_flipvals file.flips{1}{clique_ids(i)}];
end

end

