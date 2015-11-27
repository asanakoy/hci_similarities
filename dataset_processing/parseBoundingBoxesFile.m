function [bboxes] = parseBoundingBoxesFile(filepath)
% Parse *.bb file

%     fprintf('Reading boxes: %s\n', filepath);
    lines = textread(filepath, '', -1, 'delimiter', ' ', 'emptyvalue', NaN);
    bboxes = cell(size(lines, 1), 1);
    ncol = size(lines, 2);
    for i = 1:size(lines, 1)
        j = 2;
        while j <= ncol - 4
            if ~any(isnan(lines(i, j:j+4)))
                bboxes{i}(end + 1) = struct('xmin', lines(i, j), 'ymin', lines(i, j+1), ...
                'xmax', lines(i, j + 2), 'ymax', lines(i, j + 3), 'score', lines(i, j + 4));
            end
            j = j + 5;
        end
    end
    
end