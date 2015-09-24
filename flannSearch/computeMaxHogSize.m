function [ totalNumberOfVectors, maxHogSize ] = computeMaxHogSize()
%COMPUTEMAXHOGSIZE Summary of this function goes here
%   Detailed explanation goes here
PATH_TO_WHITEHOG = '/net/hciserver03/storage/asanakoy/workspace/similarities/whitehog';
    
files = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
files = {files.name};

maxHogSize = [0 0 0];% TODO: compute dynamically

totalNumberOfVectors = 0;
fprintf('Number of *.mat files: %d\n', length(files));
for i = 1:length(files)
    fprintf('\b\b\b\b\b\b\b%7d', i);
    load(files{i});
    totalNumberOfVectors = totalNumberOfVectors + size(hog, 2);
     
    hogFeatures = {hog.data};
    for j = 1:length(hogFeatures)
        
        sz = size(hogFeatures{j});
        for k=1:3
            maxHogSize(k) = max([maxHogSize(k) sz(k)]);
        end
    end
end

end

