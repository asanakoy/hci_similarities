function [] = computeHog(crops_dir_path, hog_otput_dir_path)
%Compute hog for every frame and store hogs-descriptors for every sequence 
%in separate files

if nargin < 1 || isempty(crops_dir_path)
   crops_dir_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/crops';
   hog_otput_dir_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/hog';
end

fprintf('Computing hog for crops from: %s\n Output dir: %s\n', crops_dir_path, hog_otput_dir_path);

run('/net/hciserver03/storage/asanakoy/soft/vlfeat/toolbox/vl_setup')
HOG_CELL_SIZE = 8;
mkdir(hog_otput_dir_path);

categories = getNonEmptySubdirs(crops_dir_path);
tic;
parfor i = 1:length(categories)
    fprintf('\nCat %d: \n', i);
    sequences = getNonEmptySubdirs(fullfile(crops_dir_path, categories{i}));
    mkdir(fullfile(hog_otput_dir_path, categories{i}));
    for j = 1:length(sequences)
        seq_dir_path = fullfile(crops_dir_path, categories{i}, sequences{j});
        computeHogForSequence(HOG_CELL_SIZE, seq_dir_path, hog_otput_dir_path, categories{i}, sequences{j});
    end
end
toc
end

function computeHogForSequence(hog_cell_size, seq_dir_path, ...
                               hog_otput_dir_path, category_name, sequence_name)
                           
%     fprintf('\nComputing hog for %s\n', seq_dir_path);
    
    output_filepath = fullfile(hog_otput_dir_path, category_name, [sequence_name '.mat']);
        
    crops = getFilesInDir(seq_dir_path, '.*\.png');
    hog(length(crops)) = struct('data', [], 'cname', []', 'vname',  [],...
                                'fname', [], 'isize', []);
    for k = 1:length(crops)
        im = single(imread(fullfile(seq_dir_path, crops{k})));
        hog(k).data = vl_hog(im, hog_cell_size);
        hog(k).cname = category_name;
        hog(k).vname = sequence_name;
        hog(k).fname = crops{k};
        hog(k).isize = size(im);
    end
%     fprintf('\nSaving hog data to %s\n', output_filepath);
    save(output_filepath, '-v7.3', 'hog');
end