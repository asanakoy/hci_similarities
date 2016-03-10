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

args = [96, 96];
do_for_each_sequence(crops_dir_path, resized_crops_otput_dir_path, @resize_all_crops_from_sequence, args);

end
