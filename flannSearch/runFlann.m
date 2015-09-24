function [ parameters ] = runFlann(dataset, name)
%TESTFLANN Summary of this function goes here
%   Detailed explanation goes here
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-build-visionserver01/src/matlab'
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-src/src/matlab'

%%%%%%%%%%%%%%%

build_params.algorithm = 'autotuned';
build_params.target_precision = 0.9;
build_params.build_weight = 0.01;
build_params.memory_weight = 0;
build_params.sample_fraction = 1.0;

fprintf('building index with build_params.target_precision = %f ...\n', build_params.target_precision);
tic;
[index, parameters] = flann_build_index(dataset, build_params);
toc

filePathToSaveParameters = sprintf('~/workspace/similarities/flannSearch/flannData/flannParams_%s.mat', name)
filePathToSaveIndex = sprintf('flannData/flannIndex_%s.index', name)

fprintf('saving parameters...\n');
save(filePathToSaveParameters, 'parameters');
fprintf('saving index...\n');
flann_save_index(index, filePathToSaveIndex);

fprintf('freeing index from  memory...\n');
flann_free_index(index);

end

