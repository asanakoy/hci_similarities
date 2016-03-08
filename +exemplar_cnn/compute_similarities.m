function [] = compute_similarities( category_name, dataset_path,  ...
                                     features_path, output_path )
% Calculate intra-category pairwise correlations between
% ECNN-fc5 representations of the samples from specified category.
narginchk(1,4);

if nargin == 1 
    dataset_path = '~/workspace/OlympicSports/';
    features_path = sprintf('~/workspace/OlympicSports/exemplar_cnn/features/fc5/features_%s_ecnn_fc5_15patches_zscores.mat', ...
                             category_name);
    output_path = sprintf('~/workspace/OlympicSports/exemplar_cnn/similarities/fc5/sim_%s_ecnn_fc5_15patches_zscores.mat', category_name);
end

fprintf('compute_similarities for %s\n', category_name);

if exist(output_path, 'file')
    fprintf('Skip. File %s already exists!\n', output_path);
    return
end

fprintf('Loading data info... ');
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
fprintf('[OK]\n');
fprintf('Computing category size...\n');
category_size = get_category_size(category_name, data_info);

fprintf('Opening features file... ');
file = load(features_path);
fprintf('[OK]\n');

fprintf('file.features size: %s\n', mat2str(size(file.features)));
assert(size(file.features, 1) == category_size);

fprintf('Computing correlation unflipped - unflipped ...\n');
simMatrix = single(squareform(2 - pdist(file.features, 'correlation')));

fprintf('Computing correlation unflipped - flipped ...\n');
simMatrix_flipped = single(2 - pdist2(file.features, file.features_flip, 'correlation'));

clear file

whos simMatrix
fprintf('simMatrix size: %s\n', mat2str(size(simMatrix)));
fprintf('simMatrix_flipped size: %s\n', mat2str(size(simMatrix_flipped)));
fprintf('Saving on disk...\n');
save(output_path, '-v7.3', 'simMatrix', 'simMatrix_flipped');

end
