function [] = collect_bboxes()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/export/home/asanakoy/workspace/OlympicSports';
crops_info = load(DatasetStructure.getCropsGlobalInfoPath(dataset_path));

idx_in_seq = 1;
prev_seq_name = '';
k = 0;
for i = 1:length(crops_info.crops)
    fprintf('%d\n', i);
    if strcmp(prev_seq_name, crops_info.crops(i).vname) == 0
        path = fullfile(dataset_path, 'bboxes', crops_info.crops(i).cname, ...
                        [crops_info.crops(i).vname, '.bb']);
        bboxes = olympic_sports.parse_bb_file(path);
        prev_seq_name = crops_info.crops(i).vname;
        idx_in_seq = 1;
%         k = k + size(bboxes, 1);
    else
        idx_in_seq = idx_in_seq + 1;
    end
    
    crops_info.crops(i).bbox = bboxes(idx_in_seq, :);                
end

fprintf('BBoxes num: %d\n', k);

crops = crops_info.crops;
whos crops
crops(1)

save(fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info_with_bboxes.mat'), '-v7.3', 'crops');

end

