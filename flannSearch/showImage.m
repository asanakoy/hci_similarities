function [] = showImage( frameId, files, lookupTable, label)
%showImage show Image
%   Detailed explanation goes here
    
    CROPS_PATHS = '../crops';

    [fileIndex, newImageIndex] = getSequenceIndex(frameId, lookupTable);
    imagesInfoFile = matfile(files{fileIndex});
    imageInfo = imagesInfoFile.hog(1, newImageIndex);
    imageFullPath = fullfile(CROPS_PATHS, imageInfo.cname,... 
                                          imageInfo.vname,...
                                          imageInfo.fname);
    imshow(imageFullPath);
    title(label);
end

