function [] = showImage( frameId, dataset_path, sequnceFilPathes, sequencesLookupTable, label, isFlipped)
%showImage show Image
%   Detailed explanation goes here

    if nargin < 6 || isempty(isFlipped)
       isFlipped = 0;
    end
    img = imread(getImagePath(frameId, dataset_path, sequnceFilPathes, sequencesLookupTable));
    if isFlipped
        img = fliplr(img);
    end
    imshow(img);
    title(label);
end

