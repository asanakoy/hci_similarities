function [] = create_matrix_of_images( dataset_path )
%CREATE_MATRIX_OF_IMAGES Summary of this function goes here
%   Detailed explanation goes here

crops_dir_path = fullfile(dataset_path, 'crops_227x227');

categories = getNonEmptySubdirs(crops_dir_path);
tic;
for i = 1:length(categories)
    fprintf('\nCat %d / %d: \nCurrent sequence:              ', i, length(categories));
    sequences = getNonEmptySubdirs(fullfile(crops_dir_path, categories{i}));
    
    str_width = length(sprintf('%04d/%04d', length(sequences), length(sequences)));
    clean_symbols = repmat('\b', 1, str_width);
    for j = 1:length(sequences)
        fprintf(clean_symbols);
        fprintf('%04d/%04d', j, length(sequences));
        seq_dir_path = fullfile(crops_dir_path, categories{i}, sequences{j});
        seq_crops = readAllImagesFromSequence(seq_dir_path, categories{i}, sequences{j});
        if (i == 1 && j == 1)
            crops = seq_crops;
        else
            crops = [crops seq_crops];
        end
            
    end
    fprintf('\n');
end
toc

filePathToSave = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_227x227.mat');
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'crops');

end

function [crops] = readAllImagesFromSequence(seq_dir_path, category_name, sequence_name)
    
    crops_names = getFilesInDir(seq_dir_path, '.*\.png');
    crops(length(crops_names)) = struct('img', [], 'cname', '', 'vname', sequence_name);
    for k = 1:length(crops_names)
        crops(k).img = uint8(imread(fullfile(seq_dir_path, crops_names{k})));
        crops(k).cname = category_name;
        crops(k).vname = sequence_name;
    end   
end
