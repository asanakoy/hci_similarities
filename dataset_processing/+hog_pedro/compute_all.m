function [] = compute_all()
%COMPUTE_ALL Compute Hog-Pedro and similarites for each category.

dataset_path = '~/workspace/ucf_sports';
crops_dir_name = 'crops_227x227';
output_path = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'hog_pedro_227x227.mat');
hog_pedro.compute_hog_pedro( dataset_path, crops_dir_name, output_path )

hog_pedro.compute_all_similarities(dataset_path);
end

