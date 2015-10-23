function [ objects ] = sim_esvm_create_dataset( frames_ids, dataset_path, data_info)
%Create dataset for esvm

IMAGE_SIZE = [227 227];
CROPS_DIR_NAME = 'crops_227x227';
CROPS_PATHS = fullfile(dataset_path, CROPS_DIR_NAME);

objects = cell(1, length(frames_ids));

str_width = length(sprintf('%06d/%06d', 0, 0));
clean_symbols = repmat('\b', 1, str_width);
fprintf('Reading frame: %06d/%06d', 0, length(frames_ids));     
prev_seq_index = -1;
for i = 1:length(frames_ids)
    fprintf(clean_symbols);
    fprintf('%06d/%06d', i, length(frames_ids));
        
%     info = getImageInfo(frames_ids(i), dataset_path, ...
%         data_info.sequenceFilesPathes, data_info.sequenceLookupTable, CROPS_DIR_NAME);
    
    [cur_seq_index, image_idx_inside_seq] = getSequenceIndex(frames_ids(i), data_info.sequenceLookupTable);
    if prev_seq_index ~= cur_seq_index
        prev_seq_index = cur_seq_index;
        sequenceInfoFile = load(data_info.sequenceFilesPathes{cur_seq_index});
    end
    
    image_info = sequenceInfoFile.hog(1, image_idx_inside_seq);
    absolute_path = fullfile(CROPS_PATHS, image_info.cname,... 
                                          image_info.vname,...
                                          image_info.fname);
                                      
    
    objects{i}.I = absolute_path;
    objects{i}.recs.imgsize = IMAGE_SIZE;
    objects{i}.recs.cname = image_info.cname;
    objects{i}.recs.objects(1).frame_id = frames_ids(i);
    objects{i}.recs.objects(1).class = image_info.cname;
    objects{i}.recs.objects(1).bbox = [ 1 1 IMAGE_SIZE];
    objects{i}.recs.objects(1).difficult = 0;
end
fprintf('\n');

end

