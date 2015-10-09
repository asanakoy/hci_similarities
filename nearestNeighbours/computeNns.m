
addpath(genpath('/export/home/asanakoy/workspace/similarities'));

% datase_path = '/export/home/asanakoy/workspace/OlympicSports';
datase_path = '/export/home/asanakoy/workspace/HMDB51';

if ~exist('hog', 'var')
    fprintf('loadind whitehog\n');
    load(fullfile(DatasetStructure.getDataDirPath(datase_path), 'whitehog_all.mat'));
    fprintf('loaded!\n');
end
if ~exist('categoryLookupTable', 'var')
    load (DatasetStructure.getDataInfoPath(datase_path));
end

NUM_OF_NNS = 1000;

N = totalNumberOfVectors;

NUM_BATCHES = 100;
BATCH_SIZE = floor(N / NUM_BATCHES);
fprintf('Batches:%d, BATCH_SIZE:%d\n', NUM_BATCHES, BATCH_SIZE);

NUM_OF_WORKERS = 70;
parpool('local', NUM_OF_WORKERS);

for k = 1:NUM_BATCHES
    fprintf('%s batch:%d\n', datestr(datetime('now')), k);
    
    if k ~= NUM_BATCHES
        curr_batch_size = BATCH_SIZE;
    else
        curr_batch_size = N - BATCH_SIZE * (k-1);
    end
    
    nns = cell(1, curr_batch_size);
    distances = cell (1, curr_batch_size);
    isFlipped = cell (1, curr_batch_size);
    
    begin = (k-1) * BATCH_SIZE;
    
    parfor i = 1:curr_batch_size

        fprintf('ID: %d\n', i);
        currFrameId = i + begin;
        
        [tmp_nns, tmp_distances, tmp_isFlipped] = computeNnsBySimilarity(currFrameId, hog, 1);
        [ ~, ~, nns{i}, distances{i},  isFlipped{i} ] =...
                    filterNeighbours( currFrameId, tmp_nns, tmp_distances, tmp_isFlipped, categoryLookupTable );
        
        nns{i} = nns{i}(1:1000);
        distances{i} = distances{i}(1:1000);
        isFlipped{i} = isFlipped{i}(1:1000);

    end
    fprintf('%s Batch %d ready!\n', datestr(datetime('now')), k);
    filePathToSave = fullfile(DatasetStructure.getDataDirPath(datase_path), ...
                               'conv1_nns', sprintf('%02d_nns', k));
    save(filePathToSave, '-v7.3', 'nns', 'distances', 'isFlipped');
    fprintf('%s Batch %d saved.\n', datestr(datetime('now')), k);
end

