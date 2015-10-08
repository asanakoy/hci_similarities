function [ ] = buildBigWhitehogFile(dataset_path)
PATH_TO_WHITEHOG = DatasetStructure.getWhitehogDirPath(dataset_path);
    
files = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
files = sort({files.name});

hog = {};
NUMBER_OF_FILES = length(files);

fprintf('Total number of files: %d', NUMBER_OF_FILES);
fprintf('\nReshaping and tiling HOG features\n');
fprintf('Processing file:         ');
tic;
for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    f = load(files{i});
    hog = [hog {f.hog.data}]; %#ok<AGROW>
end
fprintf('\n');
toc

filePathToSave = fullfile(DatasetStructure.getDataDirPath(dataset_path), 'whitehog_all.mat');
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'hog');

end