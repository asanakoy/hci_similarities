function [ info ] = get_image_info( frameId, data_info, crops_dir_name )
%GETIMAGEINFO Returns an object containing information about image
%
% crops_dir_name - name of the crops dir, specify if you want not default one
% info.cname - category name
% info.vname - sequence (video) name
% info.fname - filename 
% info.absolute_path - absolute path to the image

    if exist('crops_dir_name', 'var')
        CROPS_PATHS = fullfile(data_info.dataset_path, crops_dir_name);
    else
        CROPS_PATHS = fullfile(data_info.dataset_path,...
                               DatasetStructure.CROPS_DIR);
    end
    
    [fileIndex, newImageIndex] = getSequenceIndex(frameId, data_info.sequenceLookupTable);
    sequenceInfoFile = matfile(data_info.sequenceFilesPathes{fileIndex});
    imageInfo = sequenceInfoFile.hog(1, newImageIndex);
    absolute_path = fullfile(CROPS_PATHS, imageInfo.cname,... 
                                          imageInfo.vname,...
                                          imageInfo.fname);
                                      
    info.cname = imageInfo.cname;
    info.vname = imageInfo.vname;
    info.fname = imageInfo.fname;
    info.absolute_path = absolute_path;

end
