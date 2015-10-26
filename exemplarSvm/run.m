addpath(genpath('~/workspace/similarities'));
dataset_path = '~/workspace/OlympicSports';

ESVM_MODELS_DIR = '~/workspace/OlympicSports/esvm_models_tmp';
if exist(ESVM_MODELS_DIR, 'dir')
    rmdir(ESVM_MODELS_DIR, 's');
end

if ~exist('dataset', 'var')
    tic;
    fprintf('Opening dataset file...\n');
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
    labeled_data = load('~/workspace/dataset_labeling/merged_data/labels_bowling_23.10.mat');
end

for i = 1:length(labeled_data.labels)
    sim_esvm_train(labeled_data.category_offset + labeled_data.labels(i).anchor, dataset, data_info, ESVM_MODELS_DIR, RUN_TEST);
end
