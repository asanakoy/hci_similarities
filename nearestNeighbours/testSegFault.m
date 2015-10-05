function [ ] = testSegFault()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-build-visionserver01/src/matlab'
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-src/src/matlab'

fprintf('Loading data into memory');
load('/net/hciserver03/storage/asanakoy/workspace/similarities/flannSearch/flannData/flannParams_10files.mat');
load('/net/hciserver03/storage/asanakoy/workspace/similarities/hogForFlann/hogForFlann_10files.mat')

FLANN_INDEX_PATH = '/net/hciserver03/storage/asanakoy/workspace/similarities/flannSearch/flannData/flannIndex_10files.index';

fprintf('Loading index');
% index = flann_load_index('/net/hciserver03/storage/asanakoy/workspace/similarities/flannSearch/flannData/flannIndex_10files.index', hogVectors);
index = flann_load_index(FLANN_INDEX_PATH, hogVectors);

frameIndex = 1;

 
index
hogVectors(5000:5010, frameIndex)
parameters

tic;
[result, dists] = flann_search(index, hogVectors(:, frameIndex), 5,parameters);
toc
result
dists

end

