function [ ] = precomputeCategoryLookupTable()
%precomputeCategoryLookupTable Build table containing categories for each frame.
%   Saves result variables to file. 
%   categories - list of categories' names
%   categoryLookupTable - i-th element is the category that i-th frame
% belongs to. Using global indexing for all frames (not per sequence indexing).
PATH_TO_WHITEHOG = '~/workspace/similarities/whitehog';
    
files = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
files = {files.name};

dataStat = load('/net/hciserver03/storage/asanakoy/workspace/similarities/flannSearch/flannData/dataStat.mat');

categoryLookupTable = single(zeros(dataStat.totalNumberOfVectors, 1));
categories = {};

sequenceBeginIndex = 0;
sequenceEndIndex = 0;

NUMBER_OF_FILES = length(files);

fprintf('Reading files and building categoryLookupTable:         ');
for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    seqenceFile = matfile(files{i});
    
    tmp = seqenceFile.hog(1,1);
    currentCategoryName = tmp.cname;
    

    
    if (isempty(categories) || ~strcmp(categories{end}, currentCategoryName))
        categories = {categories{:} currentCategoryName};
    end
    
    sequenceBeginIndex = sequenceEndIndex + 1;
    sequenceEndIndex = sequenceBeginIndex + max(size(seqenceFile, 'hog')) - 1;
    categoryLookupTable(sequenceBeginIndex:sequenceEndIndex) = length(categories);
    
end

filePathToSave = '~/workspace/similarities/flannSearch/flannData/categoryLookupTable_all.mat';
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'files', 'categories', 'categoryLookupTable');

end

