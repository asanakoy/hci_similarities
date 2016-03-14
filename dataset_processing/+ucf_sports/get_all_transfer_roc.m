function [ results, aucs_column ] = get_all_transfer_roc( ucf_category_name )
%GET_ALL_TRANSFER_ROC Summary of this function goes here
%   Detailed explanation goes here
dataset_path = '~/workspace/ucf_sports';

olympic_sports_categories = {'basketball_layup', 'bowling', 'clean_and_jerk', ...
                             'discus_throw', 'diving_platform_10m',...
                              'diving_springboard_3m', 'hammer_throw', ...
                              'high_jump', 'javelin_throw', 'long_jump', ...
                              'pole_vault', 'shot_put', 'snatch', 'tennis_serve', ...
                              'triple_jump', 'vault'};

results = [];
for transfer_cat = olympic_sports_categories
    results = [results, ucf_sports.get_roc(dataset_path, ucf_category_name, transfer_cat{:})];
    close all;
end

aucs_column = arrayfun(@(x) x.auc, results)';
end

