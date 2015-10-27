addpath(genpath('~/workspace/similarities'));
dataset_path = '~/workspace/OlympicSports';

ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm_models';
if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? Y/N [N]: ', ESVM_MODELS_DIR);
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

if ~exist('labeled_data', 'var')
    labeled_data = load('~/workspace/dataset_labeling/merged_data/labels_long_jump_21.10.mat');
end

parfor i = 1:length(labeled_data.labels)
    frame_id = labeled_data.category_offset + labeled_data.labels(i).anchor;
    output_dir = fullfile(ESVM_MODELS_DIR, sprintf('%06d', frame_id));
    if (exist(output_dir, 'dir'))
        continue;
    end
    
    sim_esvm_train(frame_id, dataset, data_info, output_dir, RUN_TEST);
end
