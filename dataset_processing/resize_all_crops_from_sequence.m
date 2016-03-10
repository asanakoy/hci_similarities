function resize_all_crops_from_sequence(seq_dir_path, ...
                               resized_crops_otput_dir_path, category_name, sequence_name, new_image_size)
                           
    resized_seq_dir_path = fullfile(resized_crops_otput_dir_path, category_name, sequence_name);        
    if ~exist(resized_seq_dir_path, 'dir')
        mkdir(resized_seq_dir_path);          
    end
        
    crops = getFilesInDir(seq_dir_path, '.*\.jpg');

    for k = 1:length(crops)
        im = uint8(imresize(imread(fullfile(seq_dir_path, crops{k})), new_image_size));
        imwrite(im, fullfile(resized_seq_dir_path, crops{k}), 'jpg');
    end   
end