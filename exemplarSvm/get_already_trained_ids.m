function [] = get_already_trained_ids( dir_path )
%GET_ALREADY_TRAINED_IDS Dump ids of the previously trained esvm models into file

dir_path

dir_names = getNonEmptySubdirs(dir_path);
[pathstr, base_name, ext] = fileparts(dir_path);

trained_model_names = cell2mat(dir_names');

filePathToSave = fullfile(pathstr, [base_name ext '.mat']);
fprintf('\nSaveng data to %s\n', filePathToSave);
save(filePathToSave, '-v7.3', 'trained_model_names');

end

