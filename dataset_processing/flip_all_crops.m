function [] = flip_all_crops(crops_dir_path, flipped_crops_otput_dir_path)
%Flip every crop

if nargin < 1 || isempty(crops_dir_path)
   crops_dir_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports/crops_227x227';
   flipped_crops_otput_dir_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports/crops_227x227-flipped';
end

fprintf('Flipping crops from: %s\n Output dir: %s\n', crops_dir_path, flipped_crops_otput_dir_path);

if ~exist(flipped_crops_otput_dir_path, 'dir')
    mkdir(flipped_crops_otput_dir_path);
end

do_for_each_sequence(crops_dir_path, flipped_crops_otput_dir_path, @flip_all_crops_from_sequence);

end

function flip_all_crops_from_sequence(seq_dir_path, ...
                               flipped_crops_otput_dir_path, category_name, sequence_name)
                           
    flipped_seq_dir_path = fullfile(flipped_crops_otput_dir_path, category_name, sequence_name);        
    if ~exist(flipped_seq_dir_path, 'dir')
        mkdir(flipped_seq_dir_path);          
    end
        
    crops = getFilesInDir(seq_dir_path, '.*\.png');

    for k = 1:length(crops)
        im = fliplr(imread(fullfile(seq_dir_path, crops{k}), 'png'));
        imwrite(im, fullfile(flipped_seq_dir_path, crops{k}), 'png');
    end   
end