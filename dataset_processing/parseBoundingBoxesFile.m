function [boundingBoxes] = parseBoundingBoxesFile(filepath, bbox_columns_range)
% Parse *.bb file

    if nargin < 2 || isempty(bbox_columns_range) 
        bbox_columns_range = 2:5;
    end
    fprintf('Reading boxes: %s\n', filepath);
    boundingBoxes = textread(filepath, '', -1, 'delimiter', ' ', 'emptyvalue', -1);
    if size(boundingBoxes, 2) == 1
        boundingBoxes = repmat(-1, size(boundingBoxes, 1), 4);
    else
        assert(size(boundingBoxes, 2) >= 4);
        boundingBoxes = int32(boundingBoxes(:, bbox_columns_range));
    end
end