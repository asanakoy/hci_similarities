function [] = extract_images_from_category_mats()
%EXTRACT_IMAGES Summary of this function goes here
%   Detailed explanation goes here
crops_mats_path = '~/workspace/VOC/resizeCrops';
output_dir_path = '~/workspace/VOC/crops_227x227';

filenames = getFilesInDir(crops_mats_path,'.*\.mat');
for i = 1:length(filenames)
    category_output_dir = fullfile(output_dir_path, filenames{i}(1:length(filenames{i})-4));
    if ~exist(category_output_dir, 'dir')
        mkdir(category_output_dir);
    end
    
    f = load(fullfile(crops_mats_path, filenames{i}), 'sI');
    progress_struct = init_progress_string('img:', size(f.sI, 4), 5);
    for j = 1:size(f.sI, 4)
        update_progress_string(progress_struct, j);
        im = uint8(f.sI(:,:,:,j));
        filename = fullfile(category_output_dir, sprintf('%d.jpg', j-1));
        imwrite(im, filename, 'jpg');
    end
    fprintf('\n');
end

end

