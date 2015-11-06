function [] = resizeAllCrops(crops_dir_path, resized_crops_otput_dir_path)
%Resize every crop

if nargin < 1 || isempty(crops_dir_path)
   crops_dir_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports/crops';
   resized_crops_otput_dir_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports/crops_96x96';
end

fprintf('Resizing crops from: %s\n Output dir: %s\n', crops_dir_path, resized_crops_otput_dir_path);

if ~exist(resized_crops_otput_dir_path, 'dir')
    mkdir(resized_crops_otput_dir_path);
end

do_for_each_sequence(crops_dir_path, resized_crops_otput_dir_path, @resizeAllCropsFromSequence);

end

function resizeAllCropsFromSequence(seq_dir_path, ...
                               resized_crops_otput_dir_path, category_name, sequence_name)
    NEW_IMAGE_SIZE = [96, 96];
                           
    resized_seq_dir_path = fullfile(resized_crops_otput_dir_path, category_name, sequence_name);        
    if ~exist(resized_seq_dir_path, 'dir')
        mkdir(resized_seq_dir_path);          
    end
        
    crops = getFilesInDir(seq_dir_path, '.*\.png');

    for k = 1:length(crops)
        im = uint8(imresize(imread(fullfile(seq_dir_path, crops{k})), NEW_IMAGE_SIZE));
        imwrite(im, fullfile(resized_seq_dir_path, crops{k}), 'png');
    end   
end