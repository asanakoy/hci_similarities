function [] = assembleBigNnsTable(dataset_path)
%Get small nns tables crated by subprocesses and join them together
%   Saves output to file
load(DatasetStructure.getDataInfoPath(dataset_path));
NNS_DIR = fullfile(dataset_path, DatasetStructure.DATA_DIR, 'conv1_nns_parts');

NUMBER_OF_NNS = 1000;
N = totalNumberOfVectors;
NUM_BATCHES = 100;
BATCH_SIZE = floor(N / NUM_BATCHES);
fprintf('Batches:%d, BATCH_SIZE:%d\n', NUM_BATCHES, BATCH_SIZE);

nns = zeros(totalNumberOfVectors, NUMBER_OF_NNS, 'uint32');
distances = zeros(totalNumberOfVectors, NUMBER_OF_NNS, 'single');
isFlipped = zeros(totalNumberOfVectors, NUMBER_OF_NNS, 'uint8');

fprintf('Reading files and assembling big table:        ');
for i = 1:NUM_BATCHES
    fprintf('\b\b\b\b%4d', i);
    begin = (i - 1) * BATCH_SIZE + 1;
    
    if i ~= NUM_BATCHES
        end_ = i * BATCH_SIZE;
    else
        end_ = N;
    end
    
    file = load(sprintf(fullfile(NNS_DIR, '%02d_nns.mat'), i));
    
    nns(begin:end_, :) = cell2mat(file.nns)';
    distances(begin:end_, :) = cell2mat(file.distances)';
    isFlipped(begin:end_, :) = cell2mat(file.isFlipped)';
end

filePathToSave = fullfile(dataset_path, DatasetStructure.DATA_DIR, 'nns_1000.mat');
fprintf('\nsaving big table to file %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'nns', 'distances', 'isFlipped');

end

