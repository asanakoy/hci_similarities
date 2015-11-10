function [] = do_for_each_sequence(crops_dir_path, output_dir_path, function_handle)
%Apply function function_handle to every sequence in the dataset.
% function handle signature: function(seq_dir_path, output_dir_path, category_name, sequence_name)

categories = getNonEmptySubdirs(crops_dir_path);
tic;
parfor i = 1:length(categories)
    fprintf('\nCat %d / %d: \n%d.Current sequence:              ', i, i, length(categories));
    sequences = getNonEmptySubdirs(fullfile(crops_dir_path, categories{i}));
    
    str = sprintf('%04d/%04d', 0, length(sequences));
    fprintf('%s', str);
    str_width = length(str);
    clean_symbols = repmat('\b', 1, str_width);
    for j = 1:length(sequences)
        fprintf(clean_symbols);
        fprintf('%04d/%04d', j, length(sequences));
        seq_dir_path = fullfile(crops_dir_path, categories{i}, sequences{j});
        function_handle(seq_dir_path, output_dir_path, categories{i}, sequences{j});
    end
    fprintf('\n');
end
toc
end