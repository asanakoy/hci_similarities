
addpath(genpath('/export/home/asanakoy/workspace/similarities'));

fprintf('loadind whitehog\n');
load('/export/home/asanakoy/workspace/OlympicSports/data/whitehog_all.mat');
fprintf('loaded!\n');

N = 100000;


NUM_BATCHES = 100;
BATCH_SIZE = floor(N / NUM_BATCHES);
fprintf('Batches:%d, BATCH_SIZE:%d\n', NUM_BATCHES, BATCH_SIZE);

for k = 1:NUM_BATCHES
    fprintf('%s batch:%d\n', datestr(datetime('now')), k);
    nns = cell(1, BATCH_SIZE);
    distances = cell (1, BATCH_SIZE);
    isFlipped = cell (1, BATCH_SIZE);
    
    begin = (k-1) * BATCH_SIZE + 1;
    endd = k * BATCH_SIZE;
    
    parfor i = begin:endd

        fprintf('ID: %d\n', i);
        [ ~, ~, nns{i}, distances{i}, isFlipped{i} ] = ...
                                computeOtherCategoryNns(i, hog );

    end
    fprintf('%s Batch %d ready!\n', datestr(datetime('now')), k);
    filePathToSave = fullfile('/export/home/asanakoy/workspace/OlympicSports/data/conv_nns', ...
                                sprintf('%02d_nns', k));
    save(filePathToSave, '-v7.3', 'nns', 'distances', 'isFlipped');
    fprintf('%s Batch %d saved.\n', datestr(datetime('now')), k);
end
