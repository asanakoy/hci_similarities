function [] = compute_all_similarities()
%COMPUTE_ALL_SIMILARITIES Compute simmatrices for each category.

dataset_path = '~/workspace/OlympicSports';
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 1:length(data_info.categoryNames)
    fprintf('Calculation ECNN-FC5 similarities for %s...\n', data_info.categoryNames{i});
    exemplar_cnn.compute_similarities(data_info.categoryNames{i});
end

end
