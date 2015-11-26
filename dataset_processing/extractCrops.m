function [ ] = extractCrops()
    addpath(genpath('/net/hciserver03/storage/asanakoy/workspace/similarities'))

    dataset_dir = '/net/hciserver03/storage/asanakoy/workspace/HMDB51';
    local_dataset_dir = '/export/home/asanakoy/datasets/HMDB51';
    %Extract crops from video sequences
    BOXES_DIR_NAME = 'boxes';
    clips_dir_path = fullfile(dataset_dir, 'clips');
    boxes_dir_path = fullfile(dataset_dir, BOXES_DIR_NAME);

    categories = getNonEmptySubdirs(clips_dir_path);

    close all;

    CROPS_DIR_NAME = 'crops';
    FRAMES_DIR_NAME = 'frames';
    crops_dir_path = fullfile(dataset_dir, CROPS_DIR_NAME);
    NORMALIZED_CROP_DIAGONAL_LENGTH = 200;

    for i = 1:length(categories)
        fprintf('Cat %d / %d\n', i, length(categories));
        crops_cat_dir_path = fullfile(crops_dir_path, categories{i});
        clips_cat_dir_path = fullfile(clips_dir_path, categories{i});
        frames_cat_dir_path = fullfile(local_dataset_dir, FRAMES_DIR_NAME, categories{i});

        videos = getFilesInDir(clips_cat_dir_path, '.*\.avi');

        for iVideo = videos
            
            seq_dir_path = fullfile(crops_cat_dir_path, iVideo{:}(1:end-4));
            frames_dir_path = fullfile(frames_cat_dir_path, iVideo{:}(1:end-4));
            video_path =  fullfile(clips_cat_dir_path, iVideo{:});
            boxes_filepath = fullfile(boxes_dir_path, [iVideo{:}(1:end-4) '.bb']);
            if ~exist(seq_dir_path, 'dir')
                mkdir(seq_dir_path);
            end

            extractFramesFromVideo(video_path, frames_dir_path);
            boxes = parseBoundingBoxesFile(boxes_filepath);

            for j = 1:length(boxes)   
                
                frame = imread(fullfile(frames_dir_path, sprintf('I%05d.png', j)));

                for k = 1:size(boxes{j})
                    roi = bbox2roi(boxes{j}(k));
                    crop = imcrop(frame, roi);
                    crop = normalizeDiagonalLength(crop, NORMALIZED_CROP_DIAGONAL_LENGTH);
                    crop_filepath = fullfile(seq_dir_path, sprintf('I%05d_%d.png', j, k));
                    imwrite(crop, crop_filepath);
                end

            end
        end
    end

end


%% convert drom format (xmin, ymin, xmax, ymax) to (xmin, ymin, width, height)
function [roi] = bbox2roi(bbox)
    roi = [bbox.xmin, bbox.ymin, bbox.xmax - bbox.xmin,  bbox.ymax - bbox.ymin];
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

%%
function extractFramesFromVideo(video_path, output_frames_dir_path)
    if ~exist(output_frames_dir_path, 'dir')
        mkdir(output_frames_dir_path);
    end
    cmd = sprintf('cd "%s" && ffmpeg -loglevel panic -i "%s"  -f image2 I%%5d.png', ...
                  output_frames_dir_path, video_path);
    system(cmd);
end

function [normalizedImage] = normalizeDiagonalLength(im, normalizedDiagonalLength)
    scale = normalizedDiagonalLength / ((size(im, 1)^2 + size(im, 2)^2)^0.5);
    normalizedImage = imresize(im, scale);
end