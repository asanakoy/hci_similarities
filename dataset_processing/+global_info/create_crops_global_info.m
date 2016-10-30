function [] = create_crops_global_info( dataset_path, img_extension )
%CREATE_MATRIX_OF_IMAGES Summary of this function goes here
%   Detailed explanation goes here

if ~exist('img_extension', 'var')
    img_extension = 'png';
end

crops_dir_path = fullfile(dataset_path, 'crops_227x227');

categories = getNonEmptySubdirs(crops_dir_path);
tic;
for i = 1:length(categories)
    fprintf('\nCat %d / %d: \nCurrent sequence:              ', i, length(categories));
    sequences = getNonEmptySubdirs(fullfile(crops_dir_path, categories{i}));
    if isempty(sequences)
        fprintf('\nWARNING! No sequences found. Processing images in root %s\n                 ', ...
            fullfile(crops_dir_path, categories{i}));
        sequences = {''};
    end
    
    str_width = length(sprintf('%04d/%04d', length(sequences), length(sequences)));
    clean_symbols = repmat('\b', 1, str_width);
    for j = 1:length(sequences)
        fprintf(clean_symbols);
        fprintf('%04d/%04d', j, length(sequences));
        seq_dir_path = fullfile(crops_dir_path, categories{i}, sequences{j});
        seq_crops = global_info.readAllImagePathesFromSequence(seq_dir_path, categories{i}, sequences{j}, img_extension);
        if (i == 1 && j == 1)
            crops = seq_crops;
        else
            crops = [crops seq_crops];
        end
            
    end
    fprintf('\n');
end
toc

filePathToSave = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info.mat');
fprintf('\nSaving data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'crops');

end
