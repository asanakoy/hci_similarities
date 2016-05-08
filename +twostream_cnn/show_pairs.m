function [] = show_pairs(min_sim, max_sim, category_name, simMatrix, flipvals)
%SHOW_PAIRS Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/export/home/asanakoy/workspace/OlympicSports/';
simMatrix = triu(simMatrix);
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));

[a, b, is_flipped] = twostream_cnn.create_pairs(min_sim, max_sim, category_name, simMatrix, flipvals);

category_offset = get_category_offset(category_name, data_info);

f = figure(1);
for i = 1:length(a)
    subplot(1,2,1);
    showImage(category_offset + a(i), dataset_path, ...
        data_info.sequenceFilesPathes, data_info.sequenceLookupTable, num2str(a(i)), 0);
    subplot(1,2,2);
    showImage(category_offset + b(i), dataset_path, ...
        data_info.sequenceFilesPathes, data_info.sequenceLookupTable, ...
        sprintf('%.2f| %d', simMatrix(a(i), b(i)), b(i)), is_flipped(i));
    
    w = waitforbuttonpress;
    if w == 0
        disp('Button click')
    else
        disp('Key press')
    end
end


end


function [seq_name] = getSeqName(image_name)
pos = regexp(image_name, '/I.*\.png');
seq_name = image_name(1:pos-1);
end

function [cur_seq_images_indices] = getCurSeqIndices(image_id, image_names)
    cur_seq_name = getSeqName(image_names{image_id});
    cur_seq_images_indices = find(cellfun(@(z) strncmpi(z, cur_seq_name, length(cur_seq_name)), image_names));
end
