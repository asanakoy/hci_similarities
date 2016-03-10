function [] = extract_crops(category_name, BOXES_DIR_NAME, new_sequence_name_suffix)

    dataset_dir = '/net/hciserver03/storage/asanakoy/workspace/ucf_sports';
    src_dir_path = fullfile(dataset_dir, 'source');
    
    CROP_SIZE = [227, 227];
    CROPS_DIR_NAME = 'crops_227x227';
    otput_dir_path = fullfile(dataset_dir, CROPS_DIR_NAME);
    output_cat_dir_path = fullfile(otput_dir_path, category_name);
    
    src_frames_cat_dir_path = fullfile(src_dir_path, category_name);

    seq_names = getNonEmptySubdirs(src_frames_cat_dir_path);
    progress_struct = init_progress_string('Sequence:', length(seq_names), 1);
    for i = 1:length(seq_names)
        update_progress_string(progress_struct, i);
        
        i_seq_name = seq_names{i};
        src_frames_seq_dir_path = fullfile(src_frames_cat_dir_path, i_seq_name);
        output_seq_dir_path = fullfile(output_cat_dir_path, [i_seq_name, new_sequence_name_suffix]);
        
        boxes_dir_path = fullfile(src_frames_seq_dir_path, BOXES_DIR_NAME);
        
        boxes_filenames = getFilesInDir(boxes_dir_path, '.*\.tif\.txt');
        
        if isempty(boxes_filenames)
            continue;
        end
        
        if ~exist(output_seq_dir_path, 'dir')
            mkdir(output_seq_dir_path);
        end

        for j = 1:length(boxes_filenames)   
            frame_filename = sprintf('%s.jpg', boxes_filenames{j}(1:end-8));
            frame = imread(fullfile(src_frames_seq_dir_path, frame_filename));
            [box, is_ok] = ucf_sports.read_bbox(fullfile(boxes_dir_path,  boxes_filenames{j}));
            if ~is_ok
                fprintf('\n%s bbox is corrupted: [%f %f %f %f]\n', ...
                    fullfile(src_frames_seq_dir_path, frame_filename), ...
                    box.x0, box.y0, box.width, box.height);
                subsequence_number = '';
                if length(BOXES_DIR_NAME) > 2
                    subsequence_number = BOXES_DIR_NAME(3:end);
                end
                crop = imread(fullfile(src_frames_seq_dir_path, ['jpeg', subsequence_number], frame_filename));
            else
                crop = imcrop(frame, [box.x0, box.y0, box.width, box.height]);
            end
            
            
            crop = imresize(crop, CROP_SIZE);
            
            crop_filepath = fullfile(output_seq_dir_path, frame_filename);
            imwrite(crop, crop_filepath);
        end
    end
    fprintf('\n');
    
end
