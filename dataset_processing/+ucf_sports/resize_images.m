function [] = resize_images( src_crops_dir_path, resized_crops_otput_dir_path, category_name )
%RESIZE_IMAGES Summary of this function goes here
%   Detailed explanation goes here
tic;
NEW_IMAGE_SIZE = [227, 227];

seq_names = getNonEmptySubdirs(fullfile(src_crops_dir_path, category_name));  

progress_struct = init_progress_string('Sequence:', length(seq_names), 1);
for j = 1:length(seq_names)
    update_progress_string(progress_struct, j);

    seq_dir_path = fullfile(src_crops_dir_path,category_name, seq_names{j});
    resize_all_crops_from_sequence(seq_dir_path, resized_crops_otput_dir_path, category_name, seq_names{j}, NEW_IMAGE_SIZE);
end
fprintf('\n');
toc

end
