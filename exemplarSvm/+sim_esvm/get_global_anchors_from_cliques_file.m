function [ anchor_ids, anchor_flipvals ] = get_global_anchors_from_cliques_file( data_info, category_name, filepath)
%GET_ANCHORS_FROM_CLIQUES_FILE Get gloabl anchor ids from file, containing cliques
% File consists of cliques of size 2
% Consider only cliques with ids from cliques_ids, take 1 point from each
% clique randomly.

narginchk(3, 3);
nargoutchk(2, 2);


[pathstr, base_name, ext] = fileparts(filepath);
filePathToSave = fullfile(pathstr, [base_name '_Global_anchors.mat']);

if exist(filePathToSave, 'file')
    prompt = sprintf('Do you want to overwrite existing file %s? yes/N [N]: ', filePathToSave);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        fprintf('Generating new one.\n');
    else
        load(filePathToSave);
        fprintf('Loaded old file %s.\n', filePathToSave);
        return;
    end
end

file = load(filepath);

anchor_ids = [];
anchor_flipvals = false([0, 0]);
category_offset = get_category_offset(category_name, data_info);
for batch_id = 1:length(file.cliques)
    for i = 1:length(file.cliques{batch_id})
        assert(i <= length(file.cliques{batch_id}), 'incorrect clique id: %d\n', i);
        rand_id = randi(length(file.cliques{batch_id}{i}));
        anchor_ids = [anchor_ids (file.cliques{batch_id}{i}(rand_id) + category_offset)];
        anchor_flipvals = [anchor_flipvals file.flips{batch_id}{i}(rand_id)];
    end
end

fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'anchor_ids', 'anchor_flipvals');

end

