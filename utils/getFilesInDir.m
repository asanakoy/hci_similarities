function [files] = getFilesInDir(dir_path, regexp)
% Get filenames, which match the regexp,  of the files in directory. 
% Filenames are sorted lexicographically in ascending order.
% Example usage: 
%   Get al *png files in dir. 
%   filenames = getFilesInDir('/home/user/some_dir', '.*\.png');
   
    files = dir(dir_path);
    files = regexpi({files.name}, regexp, 'match');
    files = [files{:}];
    files = sort(files);
end

