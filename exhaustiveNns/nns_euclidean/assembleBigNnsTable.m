function [] = assembleBigNnsTable(dataset_path)
%Get small nns tables crated by subprocesses and join them together
%   Saves output to file
load(DatasetStructure.getDataInfoPath(dataset_path));
NNS_DIR = fullfile(dataset_path, DatasetStructure.DATA_DIR, 'nns_parts');
nWorkers = 80;
step = ceil(totalNumberOfVectors / nWorkers);

NUMBER_OF_NNS = 1000;
nns = zeros(totalNumberOfVectors, NUMBER_OF_NNS);
distances = zeros(totalNumberOfVectors, NUMBER_OF_NNS);
isFlipped = zeros(totalNumberOfVectors, NUMBER_OF_NNS);

fprintf('Reading files and assembling big table:        ');
for i = 0:(nWorkers-1)
    fprintf('\b\b\b\b%4d', i);
    begin = i * step;
    end_ = min([(i + 1) * step, totalNumberOfVectors]);
    file = load(sprintf(fullfile(NNS_DIR, 'nns_all_%05d_%05d.mat'), begin, end_));
    
    nns(begin + 1:end_, :) = file.nns;
    distances((begin + 1):end_, :) = file.distances;
    isFlipped((begin + 1):end_, :) = file.isFlipped;
end

filePathToSave = fullfile(dataset_path, DatasetStructure.DATA_DIR, 'nns_1000.mat');
fprintf('\nsaving big table to file %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'nns', 'distances', 'isFlipped');

end

