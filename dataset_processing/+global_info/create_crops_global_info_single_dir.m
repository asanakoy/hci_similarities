function [] = create_crops_global_info_single_dir( dataset_path, img_extension )
%CREATE_MATRIX_OF_IMAGES Summary of this function goes here
%   Detailed explanation goes here

if ~exist('img_extension', 'var')
    img_extension = 'png';
end

crops_dir_path = fullfile(dataset_path, 'crops/train_227x227');

tic;
category_name = '';
sequence_name = '';
sequences = getNonEmptySubdirs(fullfile(crops_dir_path, category_name));
crops = global_info.readAllImagePathesFromSequence(crops_dir_path, category_name, sequence_name, img_extension);
toc

filePathToSave = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info.mat');
fprintf('\nSaving data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'crops');

end




