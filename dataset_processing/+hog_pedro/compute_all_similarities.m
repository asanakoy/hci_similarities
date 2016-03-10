function [] = compute_all_similarities(dataset_path)
%COMPUTE_ALL_HOG_PEDRO_SIMILARITIES Summary of this function goes here
%   Detailed explanation goes here

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 1:length(data_info.categoryNames)
    fprintf('Calculation HOG-Pedro similarities for %s...\n', data_info.categoryNames{i});
    hog_pedro.compute_similarities(data_info.categoryNames{i}, dataset_path);
end

end

