function [ simMatrix, flipval ] = load_sim_matrix( dataset_path, category_name )
%LOAD_SIM_MATRIX Summary of this function goes here
%   Detailed explanation goes here
load(fullfile(dataset_path, sprintf('sim/simMatrix_%s.mat', category_name)));
end

