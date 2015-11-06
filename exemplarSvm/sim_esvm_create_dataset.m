function [ objects ] = sim_esvm_create_dataset( frames_ids, dataset_path, dataset, flipvals)
%Create dataset for esvm

if ~exist(flipvals, 'var')
    flipvals = false(size(frames_ids));
end


IMAGE_SIZE = [227 227];
CROPS_DIR_NAME = 'crops_227x227';
FLIPPED_CROPS_DIR_NAME = 'crops_227x227-flipped';
CROPS_PATHS = fullfile(dataset_path, CROPS_DIR_NAME);

objects = cell(1, length(frames_ids));

str_width = length(sprintf('%06d/%06d', 0, 0));
clean_symbols = repmat('\b', 1, str_width);
fprintf('Reading frame: %06d/%06d', 0, length(frames_ids));     

for i = 1:length(frames_ids)
    if (mod(i, 100) == 0)
        fprintf(clean_symbols);
        fprintf('%06d/%06d', i, length(frames_ids));
    end
    
    frame_id = frames_ids(i);
    if (isfield(dataset.crops(frame_id), 'img'))
        objects{i}.I = dataset.crops(frame_id).img;
        if (flipvals(i))
            objects{i}.I = fliplr(objects{i}.I);
        end
    else
        if (~flipvals(i))
            objects{i}.I = fullfile(CROPS_PATHS, dataset.crops(frame_id).img_relative_path);
        else
%             objects{i}.I = fullfile(FLIPPED_CROPS_DIR_NAME, dataset.crops(frame_id).img_relative_path);
            objects{i}.I = fliplr(imread(fullfile(CROPS_PATHS, dataset.crops(frame_id).img_relative_path), 'png'));
        end

    end
    objects{i}.recs.imgsize = IMAGE_SIZE;
    objects{i}.recs.cname = dataset.crops(frame_id).cname;
    objects{i}.recs.objects(1).frame_id = frame_id;
    objects{i}.recs.objects(1).flipval = flipvals(i);
    objects{i}.recs.objects(1).class = dataset.crops(frame_id).cname;
    objects{i}.recs.objects(1).bbox = [ 1 1 IMAGE_SIZE];
    objects{i}.recs.objects(1).difficult = 0;
end
fprintf('\n');

end

