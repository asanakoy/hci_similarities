function [ output_args ] = bb_demo( input_args )
%BB_DEMO Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '~/workspace/OlympicSports';
crops_info = load(fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info_with_bboxes.mat'));
clips_path = fullfile(dataset_path, 'clips');

for i = 6000:length(crops_info.crops)
    fprintf('%d\n', i);
    figure;
    img_path = fullfile(clips_path, [crops_info.crops(i).img_relative_path(1:end-3), 'jpg']);
    img = imread(img_path);
    imshow(img)
    hold on;

    rectangle('Position', [crops_info.crops(i).bbox(1),  crops_info.crops(i).bbox(2),  ...
                           crops_info.crops(i).bbox(3) - crops_info.crops(i).bbox(1) + 1, ...
                           crops_info.crops(i).bbox(4) - crops_info.crops(i).bbox(2) + 1]);

    hold off;
    
    pause;
    
end

end

