function [] = compute_all_hog_pedro_similarities()
%COMPUTE_ALL_HOG_PEDRO_SIMILARITIES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '~/workspace/OlympicSports';
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 1:length(data_info.categoryNames)
    fprintf('Calculation HOG-Pedro similarities for %s...\n', data_info.categoryNames{i});
    compute_hog_pedro_similarities(data_info.categoryNames{i});
end

end

