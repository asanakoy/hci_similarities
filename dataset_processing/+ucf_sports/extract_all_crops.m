function [] = extract_all_crops()
%EXTRACT_ALL_CROPS Summary of this function goes here
%   Detailed explanation goes here

    dataset_path = '/net/hciserver03/storage/asanakoy/workspace/ucf_sports';
    src_dir_path = fullfile(dataset_path, 'source');
    category_names = getNonEmptySubdirs(src_dir_path);
    
    for i = 1:length(category_names)
        category = category_names{i};
        fprintf('Extracting crops (gt) for category: %s\n', category);
        ucf_sports.extract_crops(category, 'gt', '.1');
        fprintf('Extracting crops (gt2) for category: %s\n', category);
        ucf_sports.extract_crops(category, 'gt2', '.2');
    end
    
    resized_crops_otput_dir_path = fullfile(dataset_path, 'crops_227x227');
    ucf_sports.resize_images(src_dir_path, resized_crops_otput_dir_path, 'Lifting') % Lifting does't has bboxes
end

