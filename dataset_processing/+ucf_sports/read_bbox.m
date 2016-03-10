function [bbox, is_ok] = read_bbox(bbox_filepath)
% Read bbox from text file, stored in format x0, y0, width, height
% Return bbox structure.

fileID = fopen(bbox_filepath);
text = textscan(fileID, '%f %f %f %f %s');
fclose(fileID);
assert(length(text{1}) == 1);

bbox.x0 = text{1};
bbox.y0 = text{2};
bbox.width = text{3};
bbox.height = text{4};

is_ok = (bbox.x0 > 0 && bbox.y0 > 0 && bbox.width > 10 && bbox.height > 10);

end