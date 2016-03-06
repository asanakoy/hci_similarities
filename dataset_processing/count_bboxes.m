function [labeled_frames_count, bboxes_count] = count_bboxes()

    dataset_dir = '/net/hciserver03/storage/asanakoy/workspace/HMDB51';
    %Extract crops from video sequences
    BOXES_DIR_NAME = 'boxes';
    clips_dir_path = fullfile(dataset_dir, 'clips');
    boxes_dir_path = fullfile(dataset_dir, BOXES_DIR_NAME);

    categories = getNonEmptySubdirs(clips_dir_path);
    bboxes_count = 0;
    labeled_frames_count = 0;

    for i = 1:length(categories)
        fprintf('Cat %d / %d\n', i, length(categories));
        clips_cat_dir_path = fullfile(clips_dir_path, categories{i});
        videos = getFilesInDir(clips_cat_dir_path, '.*\.avi');

        for iVideo = videos
            
            boxes_filepath = fullfile(boxes_dir_path, [iVideo{:}(1:end-4) '.bb']);
            boxes = parseBoundingBoxesFile(boxes_filepath);
            for j = 1:length(boxes) 
                if ~isempty(boxes{j})
                    labeled_frames_count = labeled_frames_count + 1;
                end
                bboxes_count = bboxes_count + length(boxes{j});
            end
        end
    end
    fprintf('Total labeled frames: %d\n', labeled_frames_count);
    fprintf('Total bonding boxes: %d\n', bboxes_count);

end