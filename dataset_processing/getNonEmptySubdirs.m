function [dirs] = getNonEmptySubdirs(dir_path)
% Get names of non-empty subdirs of directory dir_path
    dirsInfo = dir(dir_path);
    dirs = {};
    for i = 1:length(dirsInfo)
        if (~strcmp(dirsInfo(i).name, '.') && ~strcmp(dirsInfo(i).name, '..') ...
            && dirsInfo(i).isdir ...
            && length(dir(fullfile(dir_path, dirsInfo(i).name))) > 2) % remove empty dirs

                dirs = [dirs {dirsInfo(i).name}];
        end
    end
    dirs = sort(dirs);
end
