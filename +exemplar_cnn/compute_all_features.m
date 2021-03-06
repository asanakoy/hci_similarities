function [] = compute_all_features()
%COMPUTE_ALL_FEATURES Summary of this function goes here
%   Detailed explanation goes here


dataset_path = '~/workspace/OlympicSports';
output_dirpath = '~/workspace/OlympicSports/exemplar_cnn/features/fc4';

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

for i = 1:length(data_info.categoryNames)
    fprintf('Calculation ECNN features for %s...\n', data_info.categoryNames{i});
    
    exemplar_cnn.compute_features(data_info.categoryNames{i}, data_info, output_dirpath)

end


end

