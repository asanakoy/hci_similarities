function resize_all_crops_in_dir(dir_path, resized_crops_otput_dir_path, new_image_size, images_extension)
                                 
    if ~exist(resized_crops_otput_dir_path, 'dir')
        mkdir(resized_crops_otput_dir_path);          
    end
    if ~exist('images_extension', 'var')
        images_extension = 'jpg';
    end
    images_pattern = ['.*\.', images_extension];
    fprintf('Resizing all images matching %s to %s\n', images_pattern, mat2str(new_image_size));    
    crops = getFilesInDir(dir_path, images_pattern);
    
    progress_struct = init_progress_string('Crop:', length(crops), 5);
    for k = 1:length(crops)
        update_progress_string(progress_struct, k);
        im = uint8(imresize(imread(fullfile(dir_path, crops{k})), new_image_size));
        imwrite(im, fullfile(resized_crops_otput_dir_path, crops{k}), images_extension);
    end   
    fprintf('\n');
end