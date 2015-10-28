addpath(genpath('~/workspace/similarities'));
dataset_path = '~/workspace/OlympicSports';

ESVM_MODELS_DIR_PREVIOUS_ROUND = '~/workspace/OlympicSports/esvm_models_all_0.1_round1';
ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm_models_all_0.1_round2';
if exist(ESVM_MODELS_DIR, 'dir')
    prompt = sprintf('Do you want to delete existing folder %s? yes/N [N]: ', ESVM_MODELS_DIR);
    str = input(prompt,'s');
    if strcmp(str, 'yes')
        rmdir(ESVM_MODELS_DIR, 's');
        fprintf('Deleted %s.\n', ESVM_MODELS_DIR);
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
TRAIN_DATA_FRACTION = 0.1;

fprintf('Starting parpool...\n');
c = parcluster('local');
c.NumWorkers = 12;
if (~strcmp(version('-release'), '2014b'))
    matlabpool(c, c.NumWorkers);
else
    parpool(c, c.NumWorkers);
end

labels_dir_path = '~/workspace/dataset_labeling/labels_to_train';
anchor_global_ids = get_all_labeled_global_anchor_ids(labels_dir_path);

parfor i = 1:length(anchor_global_ids)
    frame_id = anchor_global_ids(i);
    fprintf('----Anchor %d\n', frame_id);
    output_dir = fullfile(ESVM_MODELS_DIR, sprintf('%06d', frame_id));
    if (exist(output_dir, 'dir'))
        continue;
    end
    
    model_file = load(fullfile(ESVM_MODELS_DIR_PREVIOUS_ROUND, ...
        sprintf('%06d', frame_id), 'models'), sprintf('%06d-svm.mat', frame_id));

    sim_esvm_train(frame_id, dataset, data_info, output_dir, TRAIN_DATA_FRACTION, RUN_TEST, model_file.models{1});
end
