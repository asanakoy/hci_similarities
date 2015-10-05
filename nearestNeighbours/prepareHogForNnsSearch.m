function [hogVectors] = prepareHogForNnsSearch()
% Resize all hog vectors to the minimal common bounding box, using tiling 

PATH_TO_WHITEHOG = '/net/hciserver03/storage/asanakoy/workspace/similarities/whitehog';
% classNames = dir(PATH_TO_WHITEHOG);
% classNames = regexpi({classNames.name},'\w*','match');
% classNames = [classNames{:}];
    
files = subdir(fullfile(PATH_TO_WHITEHOG, '*.mat'));
files = {files.name};

dataInfo = load('/net/hciserver03/storage/asanakoy/workspace/similarities/nearestNeighbours/data/dataInfo_all.mat');
NEW_SIZE = dataInfo.maxHogSize;
TOTAL_NUMBER_OF_VECTORS = dataInfo.totalNumberOfVectors;

hogVectors = zeros(prod(NEW_SIZE), TOTAL_NUMBER_OF_VECTORS);
hogVectorsFlipped = zeros(prod(NEW_SIZE), TOTAL_NUMBER_OF_VECTORS);
currentVectorIndex = 1;

NUMBER_OF_FILES = length(files);

fprintf('\nReshaping and tiling HOG features\n');
fprintf('Processing file:         ');

for i = 1:NUMBER_OF_FILES
    fprintf('\b\b\b\b\b\b\b%7d', i);
    load(files{i});
    hogFeatures = {hog.data};
    for j = 1:length(hogFeatures)
        
        newHog = tileImage(hogFeatures{j}, NEW_SIZE);
        hogVectorsFlipped(:, currentVectorIndex) = reshape(fliplr(newHog), prod(NEW_SIZE), 1);
        hogVectors(:, currentVectorIndex) = reshape(newHog, prod(NEW_SIZE), 1); % assign hog column to the column in the result matrix
        
        currentVectorIndex = currentVectorIndex +1;
    end
end

% filePathToSave = sprintf('~/workspace/similarities/hog_tiled/hog_%files.mat', NUMBER_OF_FILES);
filePathToSave = '~/workspace/similarities/hog_tiled/hog_all.mat';
filePathToSaveFlipped = '~/workspace/similarities/hog_tiled/hogFlipped_all.mat';
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'hogVectors');
save(filePathToSaveFlipped, '-v7.3', 'hogVectorsFlipped');

end

function [tiledImage] = tileImage(oldImage, newSize)

        tiledImage = zeros(newSize);
        oldSize = size(oldImage);

        start(1) = floor((newSize(1) - oldSize(1)) / 2) + 1;
        start(2) = floor((newSize(2) - oldSize(2)) / 2) + 1;
      
%         tiledImage(start(1):(start(1) - 1 + oldSize(1)), start(2):(start(2) - 1 + oldSize(2)), :) = oldImage;


        shiftX = -ceil((start(1) - 1) / oldSize(1)) : ceil((newSize(1) - start(1) - oldSize(1) + 1) / oldSize(1));
        shiftY = -ceil((start(2) - 1) / oldSize(2)) : ceil((newSize(2) - start(2) - oldSize(2) + 1) / oldSize(2));
        for i = shiftX
            for j = shiftY
                x = start(1) + i * oldSize(1);
                y = start(2) + j * oldSize(2);
                
                d1 = max([0, 1 - x]);
                d2 = max([0, 1 - y]);
                D1 = max([0, x + oldSize(1) - 1 - newSize(1)]);
                D2 = max([0, y + oldSize(2) - 1 - newSize(2)]);
                a = [x + d1, x + oldSize(1) - 1 - D1];
                b = [y + d2, y + oldSize(2) - 1 - D2];
                
                
                tiledImage(a(1):a(2), b(1):b(2), :) = oldImage((1+d1):(end-D1), (1+d2):(end-D2), :);
            end
        end
end
