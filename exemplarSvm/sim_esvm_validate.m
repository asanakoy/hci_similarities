function [] = sim_esvm_validate()
%SIM_ESVM_VALIDATE Summary of this function goes here
%   Detailed explanation goes here

output_dir = '~/workspace/OlympicSports/esvm/results';

diary(fullfile(output_dir, 'validation_log_3.txt'));

%%
use_mining = 1;
create_negatives_policy = 'random_from_other_categories';
negatives_train_data_fraction = 0.1;
[ aucs ] = sim_esvm_many_run( create_negatives_policy, negatives_train_data_fraction, use_mining);

save(fullfile(output_dir, sprintf('long_jump_mining_%d_%s_validation.mat', ...
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
% create_negatives_policy = 'negative_cliques';
% negatives_train_data_fraction = 1.0;
%  [ aucs ] = sim_esvm_many_run( create_negatives_policy, negatives_train_data_fraction);
% 
% save(fullfile(output_dir, sprintf('long_jump_%s_validation.mat', create_negatives_policy)), '-v7.3', 'aucs');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diary off



end

