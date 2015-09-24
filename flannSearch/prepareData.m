function [files, lookupTable, hogVectors] = prepareData()
%PREPAREDATA Summary of this function goes here
%   Detailed explanation goes here

PATH_TO_WHITEHOG = '~/workspace/similarities/whitehog';
% classNames = dir(PATH_TO_WHITEHOG);
% classNames = regexpi({classNames.name},'\w*','match');
% classNames = [classNames{:}];

% files = subdir(fullfile(PATH_TO_WHITEHOG, classNames{1}, '*.mat'));
% files = {files.name};
    
files = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
files = {files.name};

NEW_SIZE = [25 24 31];% TODO: compute dynamically

TOTAL_NUMBER_OF_VECTORS = 1;%113516;


hogVectors = single(zeros(prod(NEW_SIZE), TOTAL_NUMBER_OF_VECTORS));
currentVectorIndex = 1;

NUMBER_OF_FILES = 10;%length(files);
lookupTable(NUMBER_OF_FILES) = struct('begin', [], 'end', []);

fprintf('\nReshaping and zero padding HOG features\n');
fprintf('Processing file:         ');

for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    load(files{i});
    hogFeatures = {hog.data};
    lookupTable(i).begin = currentVectorIndex;
    lookupTable(i).end = lookupTable(i).begin + length(hogFeatures) - 1;
    for j = 1:length(hogFeatures)
        newHog = zeros(NEW_SIZE);
        oldSize = size(hogFeatures{j});

        left(1) = floor((NEW_SIZE(1) - oldSize(1)) / 2) + 1;
        left(2) = floor((NEW_SIZE(2) - oldSize(2)) / 2) + 1;

        newHog(left(1):(left(1) - 1 + oldSize(1)), left(2):(left(2) - 1 + oldSize(2)), :) = hogFeatures{j};
        hogVectors(:, currentVectorIndex) = reshape(newHog, prod(NEW_SIZE), 1); % assign hog column to the column in the result matrix
        
        currentVectorIndex = currentVectorIndex +1;
    end
end

filePathToSave = sprintf('~/workspace/similarities/hogForFlann/hogForFlann_%dfiles_single.mat', NUMBER_OF_FILES);
% filePathToSave = '~/workspace/similarities/hogForFlann/hogForFlann_all_single.mat';
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'files', 'lookupTable', 'hogVectors');

end

