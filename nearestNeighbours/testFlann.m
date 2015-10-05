function [ flannHandler ] = testFlann(SUFFIX)
%TESTFLANN Summary of this function goes here
%   Detailed explanation goes here
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-build-visionserver01/src/matlab'
addpath '/net/hciserver03/storage/asanakoy/soft/flann-1.8.4-src/src/matlab'

if nargin < 1 || isempty(SUFFIX)
   SUFFIX = '100files';
end

%% Init FLANN

DATASET_PATH = sprintf('~/workspace/similarities/hogForFlann/hogForFlann_%s.mat', SUFFIX);
% WARNING! Not to use relative path in FLANN_INDEX_PATH here! It will cause SEGFAULT!
FLANN_INDEX_PATH = sprintf('/net/hciserver03/storage/asanakoy/workspace/similarities/nearestNeighbours/flannData_zeropadded/flannIndex_%s.index', SUFFIX); 
PARAMETERS_PATH = sprintf('~/workspace/similarities/nearestNeighbours/flannData_zeropadded/flannParams_%s.mat', SUFFIX);

flannHandler = FlannHandler();
flannHandler.init(DATASET_PATH, FLANN_INDEX_PATH, PARAMETERS_PATH);

%%
close all;

searchedFrameId = 1000;

imageLabel = sprintf('original image. id: %d', searchedFrameId);
    showImage(searchedFrameId, flannHandler.data_.files, flannHandler.data_.lookupTable, imageLabel);
    
numberOfNns = 100;

CATEGORY_DATA_PATH = '/net/hciserver03/storage/asanakoy/workspace/similarities/nearestNeighbours/data/dataInfo_all.mat';
categoryData = load(CATEGORY_DATA_PATH);

[neighboursIds, distances] = flannHandler.getNns(flannHandler.data_.hogVectors(:, searchedFrameId), numberOfNns);   
assert(neighboursIds(1) == searchedFrameId);
neighboursIds = neighboursIds(2:end);
distances = distances(2:end);

[sameCategoryNeighbours, sameCategoryDistances, otherNeighbours, otherDistances] = ...
            filterNeighbours(searchedFrameId, neighboursIds, distances, categoryData.categoryLookupTable);

        
figure;
histfit(sameCategoryDistances); title('same category neighbours distances');
figure;
histfit(otherDistances); title('other categories neighbours distances');


for i = 1:length(otherNeighbours)
    imageLabel = sprintf('%d. id: %d; dist: %f', i, otherNeighbours(i), distances(i));
    figure;
    showImage(otherNeighbours(i), flannHandler.data_.files, flannHandler.data_.lookupTable, imageLabel);
    
%     str = input('input:','s');
%     if strcmp(str, 's')
%         figure;
%     end
end