function [] = resizeAllCrops(crops_dir_path, resized_crops_otput_dir_path)
%Compute hog for every frame and store hogs-descriptors for every sequence 
%in separate files

% if nargin < 1 || isempty(crops_dir_path)
%    crops_dir_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/crops';
%    resized_crops_otput_dir_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/crops_227x227';
% end

fprintf('Resizing crops from: %s\n Output dir: %s\n', crops_dir_path, resized_crops_otput_dir_path);

if ~exist(resized_crops_otput_dir_path, 'dir')
    mkdir(resized_crops_otput_dir_path);
end

categories = getNonEmptySubdirs(crops_dir_path);
tic;
parfor i = 1:length(categories)
    fprintf('\nCat %d / %d: \nCurrent sequence:              ', i, length(categories));
    sequences = getNonEmptySubdirs(fullfile(crops_dir_path, categories{i}));
    
    str_width = length(sprintf('%04d/%04d', length(sequences), length(sequences)));
    clean_symbols = repmat('\b', 1, str_width);
    for j = 1:length(sequences)
        fprintf(clean_symbols);
        fprintf('%04d/%04d', j, length(sequences));
        seq_dir_path = fullfile(crops_dir_path, categories{i}, sequences{j});
        resizeAllCropsFromSequence(seq_dir_path, resized_crops_otput_dir_path, categories{i}, sequences{j});
    end
    fprintf('\n');
end
toc
end

function resizeAllCropsFromSequence(seq_dir_path, ...
                               resized_crops_otput_dir_path, category_name, sequence_name)
    NEW_IMAGE_SIZE = [227, 227];
                           
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