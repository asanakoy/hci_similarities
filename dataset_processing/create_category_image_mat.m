function [] = create_category_image_mat(crops_dir_path)
    images = subdir(fullfile(crops_dir_path, '*.jpg'));
    image_pathes = sort(arrayfun(@(x) x.name, images, 'UniformOutput', false));
    
    progress_struct = init_progress_string('Sequence:', length(image_pathes), 1);
    for i = 1:length(image_pathes)
        update_progress_string(progress_struct, i);
        
        im = uint8(imread(image_pathes{i}));
        if i == 1
            images_mat = zeros(size(im, 1), size(im, 2), size(im, 3), length(image_pathes),  'uint8');
        end
        images_mat(:, :, :, i) = im;
    end
    fprintf('\n');
    fprintf('Saving on disk...\n');
    save(fullfile(crops_dir_path, 'images_test.mat'), '-v7.3', 'images_mat');
end