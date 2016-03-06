function [] = sim_esvm_validate()
%SIM_ESVM_VALIDATE Summary of this function goes here
%   Detailed explanation goes here

output_dir = '~/workspace/OlympicSports/esvm/results';

diary(fullfile(output_dir, 'clique_svm_validation_log_autobalancing_zscores.txt'));

%%

create_negatives_policy = 'random_from_other_categories';
negatives_train_data_fraction = 0.1;
use_mining = 1;
use_wieghts_auto_balancing = 1;
training_type = 'clique_svm';
[ aucs ] = sim_esvm_many_run( create_negatives_policy,...
    negatives_train_data_fraction, use_mining, use_wieghts_auto_balancing, training_type);

save(fullfile(output_dir, sprintf('long_jump_clique_svm_mining_%d_%s_weights_auto_balancing_zscores_validation.mat', ...
    use_mining, ...
    create_negatives_policy)), '-v7.3', 'aucs');
% 
% %%
% create_negatives_policy = 'random_from_same_category';
% negatives_train_data_fraction = 1.0;
% [ aucs ] = sim_esvm_many_run( create_negatives_policy, negatives_train_data_fraction);
% 
% save(fullfile(output_dir, sprintf('long_jump_%s_validation.mat', create_negatives_policy)), '-v7.3', 'aucs');
% %%
% create_negatives_policy = 'random_from_other_categories';
% negatives_train_data_fraction = 0.1;
% use_mining = 1;
% use_wieghts_auto_balancing = 1;
% [ aucs ] = sim_esvm_many_run( create_negatives_policy,...
%     negatives_train_data_fraction, use_mining, use_wieghts_auto_balancing);
% 
% save(fullfile(output_dir, sprintf('long_jump_mining_%d_%s_weights_auto_balancing_preRELU_validation.mat', ...
%     use_mining, ...
%     create_negatives_policy)), '-v7.3', 'aucs');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diary off



end

