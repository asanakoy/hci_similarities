function [] = compute_all_similarities()
%COMPUTE_ALL_HOG_PEDRO_SIMILARITIES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports';
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 7:length(data_info.categoryNames)
    fprintf('Calculation HOG-Pedro similarities for %s...\n', data_info.categoryNames{i});
    hog_pedro.compute_similarities(data_info.categoryNames{i});
end

end

