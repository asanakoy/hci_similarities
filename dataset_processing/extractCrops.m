function [ ] = extractCrops()

    dataset_dir = '/net/hciserver03/storage/asanakoy/workspace/HMDB51';
    local_dataset_dir = '/export/home/asanakoy/datasets/HMDB51';
    %Extract crops from video sequences
    BOXES_DIR_NAME = 'Boxes_INRIA';
    clips_dir_path = fullfile(dataset_dir, 'Clips');
    boxes_dir_path = fullfile(dataset_dir, BOXES_DIR_NAME);

    categories = getNonEmptySubdirs(clips_dir_path);

    close all;

    CROPS_DIR_NAME = 'crops';
    FRAMES_DIR_NAME = 'frames';
    crops_dir_path = fullfile(dataset_dir, CROPS_DIR_NAME);
    NORMALIZED_CROP_DIAGONAL_LENGTH = 200;

    for i = 1:length(categories)
        
        crops_cat_dir_path = fullfile(crops_dir_path, categories{i});
        clips_cat_dir_path = fullfile(clips_dir_path, categories{i});
        frames_cat_dir_path = fullfile(local_dataset_dir, FRAMES_DIR_NAME, categories{i});

        videos = getFilesInDir(clips_cat_dir_path, '.*\.avi');

        for iVideo = videos
            
            seq_dir_path = fullfile(crops_cat_dir_path, iVideo{:}(1:end-4));
            frames_dir_path = fullfile(frames_cat_dir_path, iVideo{:}(1:end-4));
            video_path =  fullfile(clips_cat_dir_path, iVideo{:});
            boxes_filepath = fullfile(boxes_dir_path, [iVideo{:}(1:end-4) '.bb']);
            mkdir(seq_dir_path);

            extractFramesFromVideo(video_path, frames_dir_path);
            boxes_filepath
            boxes = parseBoundingBoxesFile(boxes_filepath, 2:5);

            cur_frame_idx = 1;
            crops_number = 0;
            fprintf('Cropping and resizing frames\n');
            for j = 1:length(boxes)   
                
                frame = imread(fullfile(frames_dir_path, sprintf('I%05d.png', j)));
                
                if (length(find(boxes(j, :) >= 0)) == 4)
                    
                    crop = imcrop(frame, boxes(j, :));
                    crop = normalizeDiagonalLength(crop, NORMALIZED_CROP_DIAGONAL_LENGTH);
                    crop_filepath = fullfile(seq_dir_path, sprintf('I%05d.png', crops_number));
                    imwrite(crop, crop_filepath);
                    crops_number = crops_number + 1;
                    
                end
            end
        end
    end

end

% function [] = uncompressVideo(inputVideoPath, outputVideoPath)
%     fprintf('Uncompressing video %s\n', inputVideoPath);
%     if ~exist(outputVideoPath, 'file')
%         cmd = sprintf('ffmpeg -loglevel panic -i "%s" -an -vcodec rawvideo -y "%s"', inputVideoPath, outputVideoPath)
%         system(cmd);
%     else
%         fprintf('already uncompressed\n');
%     end
% end

function extractFramesFromVideo(video_path, output_frames_dir_path)
    mkdir(output_frames_dir_path);
    cmd = sprintf('cd "%s" && ffmpeg -loglevel panic -i "%s"  -f image2 I%%5d.png', ...
                  output_frames_dir_path, video_path)
    system(cmd);
end

function [normalizedImage] = normalizeDiagonalLength(im, normalizedDiagonalLength)
    scale = normalizedDiagonalLength / ((size(im, 1)^2 + size(im, 2)^2)^0.5);
    normalizedImage = imresize(im, scale);
end