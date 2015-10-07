function [] = buildAllSimMatrices( dataset_path )
%Build similatity matrices for each category.
% crops, whitehog and pairwise_sim must be computed before running this procedure


fprintf('Building pairwise sim matrices inside each category\n');
pairwise_similarities(fullfile(dataset_path, DatasetStructure.WHITEHOG_DIR),...
                      fullfile(dataset_path, DatasetStructure.PAIRWISE_SIM_DIR));

categories = getNonEmptySubdirs(fullfile(dataset_path, CROPS_DIR));
for i = 1:length(categories)
    fprintf('Building sim matrix for category %d/%d ...\n', i, length(categories));
    buildSimMatrixFromPairwise(categories{i}, ... 
                                  fullfile(dataset_path, DatasetStructure.PAIRWISE_SIM_DIR)), ...
                                  fullfile(dataset_path, DatasetStructure.CROPS_DIR),...
                                  fullfile(dataset_path, DatasetStructure.SIM_DIR);
end

end

