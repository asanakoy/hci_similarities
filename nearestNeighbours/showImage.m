function [] = showImage( frameId, sequnceFilPathes, sequencesLookupTable, label, isFlipped)
%showImage show Image
%   Detailed explanation goes here

if nargin < 5 || isempty(isFlipped)
   isFlipped = 0;
end
    img = imread(getImagePath(frameId, sequnceFilPathes, sequencesLookupTable));
    if isFlipped
        img = fliplr(img);
    end
    imshow(img);
    title(label);
end

