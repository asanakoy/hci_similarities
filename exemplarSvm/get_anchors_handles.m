function [ handles ] = get_anchors_handles( global_anchors_filepath )
%GET_ANCHORS_HANDLES Generate handles (folder name) for anchor models

if ~exist(global_anchors_filepath, 'file')
    error('File %s doesnt exist!', global_anchors_filepath);
end

load(global_anchors_filepath);
fprintf('Loaded file %s.\n', global_anchors_filepath);

handles = cell(1, length(anchor_ids));

for i = 1:length(handles)
    handles{i} = sprintf('%06d', anchor_ids(i));
    if anchor_flipvals(i)
        handles{i} = [handles{i} '_flipped'];
    end
end

end

