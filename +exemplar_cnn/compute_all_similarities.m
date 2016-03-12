function [] = compute_all_similarities()
%COMPUTE_ALL_SIMILARITIES Compute simmatrices for each category.

dataset_path = '~/workspace/OlympicSports';
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 1:length(data_info.categoryNames)
    if strcmp(data_info.categoryNames{i}, 'clean_and_jerk')
        continue;
    end
    fprintf('Calculation ECNN-FC4 similarities for %s...\n', data_info.categoryNames{i});
    exemplar_cnn.compute_similarities(data_info.categoryNames{i});
end

fprintf('Calculation ECNN-FC4 similarities for %s...\n', 'clean_and_jerk');
exemplar_cnn.compute_similarities('clean_and_jerk');

end
