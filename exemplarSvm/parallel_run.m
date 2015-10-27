addpath(genpath('~/workspace/similarities'));
dataset_path = '~/workspace/OlympicSports';

ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm_models';
if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? yes/N [N]: ', ESVM_MODELS_DIR);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        rmdir(ESVM_MODELS_DIR, 's');
        fprintf('Deleted %s.', ESVM_MODELS_DIR);
    end
end

if ~exist('dataset', 'var')
    tic;
    fprintf('Reading dataset file...\n');
%     CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_227x227.mat');
    CROPS_ARRAY_FILEPATH = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info.mat');
    dataset = load(CROPS_ARRAY_FILEPATH);
    toc
end

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

RUN_TEST = 0;

fprintf('Starting parpool...\n');
c = parcluster('local');
c.NumWorkers = 12;
parpool(c, c.NumWorkers);

% if ~exist('labeled_data', 'var')
%     labeled_data = load('~/workspace/dataset_labeling/merged_data/labels_long_jump_21.10.mat');
% end
labels_dir_path = '~/workspace/dataset_labeling/untrained_data';
file_list = getFilesInDir(labels_dir_path, '.*\.mat');
for file_id = 1:length(file_list)
    frpintf('File: %s\n', file_list{file_id});
    
    labeled_data = load(fullfile(labels_dir_path, file_list{file_id}));

    parfor i = 1:length(labeled_data.labels)
        frame_id = labeled_data.category_offset + labeled_data.labels(i).anchor;
        output_dir = fullfile(ESVM_MODELS_DIR, sprintf('%06d', frame_id));
        if (exist(output_dir, 'dir'))
            continue;
        end

        sim_esvm_train(frame_id, dataset, data_info, output_dir, RUN_TEST);
    end
    
end