function [] = compute_hog_pedro_similarities( dataset_path, category_name, ...
                                              hog_pedro_path, hog_file_flipped, output_path )
% Calculate intra-category pairwise correlations between
% pedro-HOG representations of the samples from specified category. 

if nargin == 0
    dataset_path = '~/workspace/OlympicSports/';
    category_name = 'long_jump';
    hog_pedro_path = '~/workspace/OlympicSports/data/hog_pedro_227x227_nonflipped.mat';
    hog_pedro_flipped_path = '~/workspace/OlympicSports/data/hog_pedro_227x227_flipped.mat';
    output_path = '~/workspace/OlympicSports/sim_pedro_hog/sim_hog_pedro_long_jump.mat';
end

fprintf('Loading data info... ');
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
fprintf('[OK]\n');

fprintf('Computing category offset...\n');
category_offset = get_category_offset(category_name, data_info);
fprintf('Computing category size...\n');
category_size = get_category_size(category_name, data_info);

fprintf('Opening hog files... ');
hog_file = matfile(hog_pedro_path);
hog_flipped_file = matfile(hog_pedro_flipped_path);
fprintf('[OK]\n');

hog_matrix = get_hog_matrix_for_category(hog_file, 'hog', category_offset, category_size);
hog_matrix_flipped = get_hog_matrix_for_category(hog_flipped_file, 'hog_flipped', category_offset, category_size);

fprintf('hog_matrix size: %s\n', mat2str(size(hog_matrix)));
assert(size(hog_matrix, 1) == category_size);

fprintf('Computing correlation unflipped - unflipped ...\n');
simMatrix = squareform(2 - pdist(hog_matrix, 'correlation'));

fprintf('Computing correlation unflipped - flipped ...\n');
simMatrix_flipped = 2 - pdist2(hog_matrix, hog_matrix_flipped, 'correlation');

whos simMatrix
fprintf('simMatrix size: %s\n', mat2str(size(simMatrix)));
fprintf('simMatrix_flipped size: %s\n', mat2str(size(simMatrix_flipped)));
fprintf('Saving on disk...\n');
save(output_path, '-v7.3', 'simMatrix', 'simMatrix_flipped');

end

function hog_matrix = get_hog_matrix_for_category(hog_file, fieldname, category_offset, category_size)
% Return M x N matrix, containing hog representations in rows.
% Each row is reshaped into plain vector HOG feature. 
% M is number of samples, N is number of dimensions in HOG vector.
fprintf('getting hog_matrix for category. [%s]\n', fieldname);

hog_for_category = hog_file.(fieldname)(:, :, :, category_offset + 1: category_offset + category_size);
fprintf('Num of hog vectors: %d\n', length(hog_for_category));

hog_matrix = [];
for i = 1:length(hog_for_category)
    hog_matrix = cat(1, hog_matrix, reshape(hog_for_category(:, :, :, i), 1, []));
end

clear hog_for_category
end