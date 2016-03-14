function [] = compute_all_transfer_sim_matrices()
%COMPUTE_ALL_FEATURES Summary of this function goes here
%   Detailed explanation goes here


dataset_path = '~/workspace/ucf_sports';
features_output_dirpath = fullfile(dataset_path, 'exemplar_cnn/features/fc4');
similarities_output_dirpath = fullfile(dataset_path, 'exemplar_cnn/similarities/fc4');

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

source_transfer_categories = {'diving_springboard_3m', 'hammer_throw', ...
                               'hammer_throw', 'long_jump'};
dest_categories = {'Swing-SideAngle', 'Swing-Bench', 'Kicking', 'Run-Side'};

if ~exist(features_output_dirpath, 'dir')
    mkdir(features_output_dirpath);
end
if ~exist(similarities_output_dirpath, 'dir')
    mkdir(similarities_output_dirpath);
end



for i = 1:length(dest_categories)
    dest_category_name = dest_categories{i};
    source_transfer_category = source_transfer_categories{i};
    
    features_path = fullfile(features_output_dirpath, ...
        sprintf('features_%s_%s_ecnn_fc4_36patches_quadrantpool_zscores.mat', ...
        dest_category_name, source_transfer_category));
    similarities_path = fullfile(similarities_output_dirpath, ...
        sprintf('sim_%s_%s_ecnn_fc4_36patches_quadrantpool_zscores.mat', ...
        dest_category_name, source_transfer_category));
    
    fprintf('Calculation ECNN features for %s... transfering from %s.\n', dest_category_name, source_transfer_category);

    ucf_sports.ecnn.compute_features(dest_category_name, source_transfer_category,...
                                     data_info, features_path)
    
    fprintf('Calculation ECNN-FC4 similarities for %s...\n', dest_category_name);
    exemplar_cnn.compute_similarities(dest_category_name, dataset_path, ...
                                     features_path, similarities_path); 
    
end


end

