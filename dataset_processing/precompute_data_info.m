function [ ] = precompute_data_info(dataset_path, images_extension, is_single_dir)
%precomputeCategoryLookupTable Build table containing categories for each frame.
%   Saves result variables to file. 
%   categories - list of categories' names
%   categoryLookupTable - i-th element is the category that i-th frame
%                         belongs to. Using global indexing for all frames (not per sequence indexing).
%   totalNumberOfVectors - total number of samples

% if nargin < 1 || isempty(dataset_path)
%     dataset_path = '/dir'
% end 
fprintf('Precomputing DataInfo...\n');
if ~exist('images_extension', 'var')
    images_extension = 'jpg';
end
if ~exist('is_single_dir', 'var')
    is_single_dir = 0;
end

CROPS_DIR_NAME = 'crops_227x227';
crops_path = fullfile(dataset_path, CROPS_DIR_NAME);

if is_single_dir == 1
    categoryNames = {''};
else
    categoryNames = getNonEmptySubdirs(crops_path);
end


totalNumberOfVectors = 0;
categoryLookupTable = int16.empty(0, 0);

for i = 1:length(categoryNames)
    prev_counter = totalNumberOfVectors;
    current_category_name = categoryNames{i};
    
    if is_single_dir == 1
        seq_names = {''};
    else
        seq_names = getNonEmptySubdirs(fullfile(crops_path, current_category_name));
    end
    if isempty(seq_names)
        fprintf('WARNING! No sequences found. Processing images in root %s\n', fullfile(crops_path, current_category_name));
        seq_names = {''};
    end
    
    progress_struct = init_progress_string('Sequence:', length(seq_names), 1);
    for j = 1:length(seq_names)
        update_progress_string(progress_struct, j);
        
        images_filenames = getFilesInDir(fullfile(crops_path, current_category_name, seq_names{j}), ...
                                         ['.*\.', images_extension]);
        totalNumberOfVectors = totalNumberOfVectors + length(images_filenames);
        
    end
    fprintf('\n');
    

    categoryLookupTable((prev_counter + 1):totalNumberOfVectors) = i;
end


filePathToSave = DatasetStructure.getDataInfoPath(dataset_path);
fprintf('\nSaving data to %s\n', filePathToSave);

save(filePathToSave, '-v7.3', 'categoryNames', 'categoryLookupTable', 'totalNumberOfVectors');

data_info = load(filePathToSave);
check_data_info(data_info, crops_path);

end
