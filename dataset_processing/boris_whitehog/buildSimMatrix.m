function [simMatrix] = buildSimMatrix( category )
%BUILDSIMMATRIX Summary of this function goes here
%   Detailed explanation goes here
%     pathsim = fullfile('/net/hciserver03/storage/asanakoy/workspace/HMDB51/pairwise_sim', category);
%     path_crops = fullfile('/net/hciserver03/storage/asanakoy/workspace/HMDB51/crops', category);
%     pathsave = fullfile('/net/hciserver03/storage/asanakoy/workspace/HMDB51/similarities');

    pathsim = fullfile('/net/hciserver03/storage/mbautist/Desktop/mbautista/Exemplar_CNN/pairwise_sim', category);
    path_crops = fullfile('/net/hciserver03/storage/mbautist/Desktop/mbautista/Exemplar_CNN/crops', category);
    pathsave = fullfile('/net/hciserver03/storage/asanakoy/workspace/tmp_similarities');

    seq_names = getNonEmptySubdirs(path_crops);

    image_names = [];
    for i = 1:length(seq_names)
        crop_names = getFilesInDir(fullfile(path_crops, seq_names{i}), '.*\.png');
        for j = 1:length(crop_names)
            image_names(end+1,:) = ['./', seq_names{i}, '/', crop_names{j}];
        end
    end

    fprintf('Sequence: >%5d/%5d', 0, length(seq_names));
    simAux = cell(1, length(seq_names));
    for i = 1:length(seq_names)
        fprintf('\b\b\b\b\b\b\b\b\b\b\b%5d/%5d', i, length(seq_names));
        
        % Get all similarity *.mat files for the current i-th sequence
        cur_seq_mat_fileinfos = dir([pathsim,'/',seq_names{i},'*.mat']);
        cur_seq_mat_filenames = sort({cur_seq_mat_fileinfos.name});
        for j = 1:length(cur_seq_mat_filenames)

            load(fullfile(pathsim, cur_seq_mat_filenames{j}),'val')
            if j == 1
                assert(strcmp([seq_names{i} '__' seq_names{i} '.mat'], cur_seq_mat_filenames{j}) == 1);
                %sim = max(val,[],3);
                val(:,:,1) = (val(:,:,1)+val(:,:,1)')/2;
                val(:,:,2) = (val(:,:,2)+val(:,:,2)')/2;
            end
            simAux{i}{j} = val;
        end
        if i == 1
            mat = cell2mat(simAux{1}); % get the first block-row
            total_number_of_columns = size(mat,2);
        end 
        zero_column_padding_width = total_number_of_columns - size(cell2mat(simAux{i}), 2); % == 0 for i = 1
        sz = [size(cell2mat(simAux{i}), 1), zero_column_padding_width, 2];
        simAux{i} = [zeros(sz) cell2mat(simAux{i})]; % here we will get upper-triangular block matrix

    end
    fprintf('\n');
    fprintf('total number of columns (frames): %d\n', total_number_of_columns);
    
    sim = cell2mat(simAux'); % simAux' because simAux containf row of cells simAux(1:end)
    
    % Mirror above diagonal elements into under diagonal elements (make symmetric matrix).
    for i = 1:2
        upperTriangle = triu(sim(:,:,i));
        d = diag(diag(upperTriangle));
        simMatrix(:,:,i) = (upperTriangle+upperTriangle') - d;
    end


    [simMatrix, flipval] = max(simMatrix, [], 3);
    flipval = flipval - 1;
    mkdir(pathsave);
    save(fullfile(pathsave, ['/simMatrix_', category, '.mat']), 'simMatrix', 'flipval', 'image_names', 'seq_names', '-v7.3');
end

