function [ ] = precomputeDataInfo()
%precomputeCategoryLookupTable Build table containing categories for each frame.
%   Saves result variables to file. 
%   categories - list of categories' names
%   categoryLookupTable - i-th element is the category that i-th frame
% belongs to. Using global indexing for all frames (not per sequence indexing).
PATH_TO_WHITEHOG = '/net/hciserver03/storage/asanakoy/workspace/similarities/whitehog';
    
sequenceFilesPathes = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
sequenceFilesPathes = {sequenceFilesPathes.name};

sequenceBeginIndex = 0;
sequenceEndIndex = 0;

NUMBER_OF_FILES = length(sequenceFilesPathes);
totalNumberOfVectors = 0;
maxHogSize = [0 0 0];
sequenceLookupTable(NUMBER_OF_FILES) = struct('begin', [], 'end', []);
categoryLookupTable = [];
categoryNames = {};

fprintf('Reading files and building categoryLookupTable:         ');
for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    seqenceFile = load(sequenceFilesPathes{i});
    
    totalNumberOfVectors = totalNumberOfVectors + size(seqenceFile.hog, 2);
        
    tmp = seqenceFile.hog(1,1);
    currentCategoryName = tmp.cname;
    
    if (isempty(categoryNames) || ~strcmp(categoryNames{end}, currentCategoryName))
        categoryNames = {categoryNames{:} currentCategoryName};
    end
    
    sequenceBeginIndex = sequenceEndIndex + 1;
    sequenceEndIndex = sequenceBeginIndex + max(size(seqenceFile.hog)) - 1;
    categoryLookupTable(sequenceBeginIndex:sequenceEndIndex) = length(categoryNames);
    
    sequenceLookupTable(i).begin = sequenceBeginIndex;
    sequenceLookupTable(i).end = sequenceEndIndex;
    
    hogFeatures = {seqenceFile.hog.data};
    for j = 1:length(hogFeatures)
        sz = size(hogFeatures{j});
        for k=1:3
            maxHogSize(k) = max([maxHogSize(k) sz(k)]);
        end
    end
    
end

filePathToSave = '~/workspace/similarities/nearestNeighbours/data/dataInfo_all.mat';
fprintf('\nSaving data to %s\n', filePathToSave);

save(filePathToSave, '-v7.3', 'sequenceFilesPathes', 'categoryNames', 'sequenceLookupTable', 'categoryLookupTable', 'maxHogSize', 'totalNumberOfVectors');

end
