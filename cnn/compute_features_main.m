addpath(genpath(Config.SELF_ROOT));
dataset_path = '~/workspace/OlympicSports';

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

for i = 1:length(data_info.categoryNames)
    computeCNNFeatures(data_info.categoryNames{i}, data_info);
end