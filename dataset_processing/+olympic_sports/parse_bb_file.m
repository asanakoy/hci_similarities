function [bboxes] = parse_bb_file(filepath)
% Parse *.bb file
%     fprintf('Reading boxes: %s\n', filepath);
    bboxes = textread(filepath, '', -1, 'delimiter', ' ', 'emptyvalue', NaN);
    bboxes = bboxes(:, 2:5);
end