function [ ] = precomputeDataInfo(dataset_path)
%precomputeCategoryLookupTable Build table containing categories for each frame.
%   Saves result variables to file. 
%   categories - list of categories' names
%   categoryLookupTable - i-th element is the category that i-th frame
% belongs to. Using global indexing for all frames (not per sequence indexing).

% if nargin < 1 || isempty(dataset_path)
%     dataset_path = '/dir'
% end 

whitehog_path = DatasetStructure.getWhitehogDirPath(dataset_path);

addpath('../lib'); % for subdir(...)
sequenceFilesPathes = subdir(fullfile(whitehog_path, '*.mat'));
sequenceFilesPathes = sort({sequenceFilesPathes.name});

sequenceBeginIndex = 0;
sequenceEndIndex = 0;

NUMBER_OF_FILES = length(sequenceFilesPathes);
totalNumberOfVectors = 0;
maxHogSize = [0 0 0];
sequenceLookupTable(NUMBER_OF_FILES) = struct('begin', int32.empty(0, 0), 'end', int32.empty(0, 0));
categoryLookupTable = int16.empty(0, 0);
categoryNames = {};

fprintf('Total number of files: %d', NUMBER_OF_FILES);
fprintf('Reading files and building categoryLookupTable:         ');
for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    seqenceFile = load(sequenceFilesPathes{i});
    
    totalNumberOfVectors = totalNumberOfVectors + size(seqenceFile.hog, 2);
        
    tmp = seqenceFile.hog(1,1);
    currentCategoryName = tmp.cname;
    
    if (isempty(categoryNames) || ~strcmp(categoryNames{end}, currentCategoryName))
        categoryNames = [categoryNames {currentCategoryName}];
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

filePathToSave = DatasetStructure.getDataInfoPath(dataset_path);
fprintf('\nSaving data to %s\n', filePathToSave);

save(filePathToSave, '-v7.3', 'sequenceFilesPathes', 'categoryNames', 'sequenceLookupTable', 'categoryLookupTable', 'maxHogSize', 'totalNumberOfVectors');

end
