function [crops] = readAllImagePathesFromSequence(seq_dir_path, category_name, sequence_name, img_extension)
    
    crops_names = getFilesInDir(seq_dir_path, ['.*\.', img_extension]);
    crops(length(crops_names)) = struct('img_relative_path', [], 'cname', '', 'vname', sequence_name);
    for k = 1:length(crops_names)
        crops(k).img_relative_path = fullfile(category_name, sequence_name, crops_names{k});
        crops(k).cname = category_name;
        crops(k).vname = sequence_name;
    end   
end