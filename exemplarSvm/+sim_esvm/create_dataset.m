function [ objects ] = create_dataset( frames_ids, params, flipvals)
%Create dataset for esvm

if ~exist('flipvals', 'var')
    error('NO FLIPS specified!');
end


IMAGE_SIZE = [227 227];
CROPS_DIR_NAME = 'crops_227x227';
FLIPPED_CROPS_DIR_NAME = 'crops_227x227-flipped';
CROPS_PATHS = fullfile(params.dataset_path, CROPS_DIR_NAME);

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
    if (isfield(params.crops_global_info.crops(frame_id), 'img'))
        objects{i}.I.img = params.crops_global_info.crops(frame_id).img;
        if (flipvals(i))
            objects{i}.I.img = fliplr(objects{i}.I);
        end
    else
        if (~flipvals(i))
            objects{i}.I.img = fullfile(CROPS_PATHS, params.crops_global_info.crops(frame_id).img_relative_path);
        else
%             objects{i}.I = fullfile(FLIPPED_CROPS_DIR_NAME, params.crops_global_info.crops(frame_id).img_relative_path);
            objects{i}.I.img = imread(fullfile(CROPS_PATHS, params.crops_global_info.crops(frame_id).img_relative_path), 'png');    
            objects{i}.I.img = utils.fliplr(objects{i}.I.img);
        end

    end
    objects{i}.I.id = frame_id;
    objects{i}.I.flipval = flipvals(i);
    if params.should_load_features_from_disk == 1
        assert(isfield(params, 'features_data'));
%         assert(frame_id <= size(params.features_data.features, 1), ...
%             'frame_id %d is out of bounds. Max feature index is: %d', frame_id, size(params.features_data.features, 1));
        if ~flipvals(i)
            objects{i}.I.feature = params.features_data.get_feature(frame_id, 0, params.use_plain_features);
            objects{i}.I.feature_flipped = params.features_data.get_feature(frame_id, 1, params.use_plain_features);
        else
            % WARNING: should be used only for Exemlpars or positive training set! Negatives must be
            % flipped on-line during running ESVM training and thats why
            % contain both fields 'feature' and 'feature_flipped'
            % Note: actualy right now we don't support flipped exemplars.
            objects{i}.I.feature = params.features_data.get_feature(frame_id, 1, params.use_plain_features);
        end
    end
    
    objects{i}.I.imgsize = IMAGE_SIZE;
    objects{i}.recs.imgsize = IMAGE_SIZE;
    objects{i}.recs.cname = params.crops_global_info.crops(frame_id).cname;
    objects{i}.recs.objects(1).frame_id = frame_id;
    objects{i}.recs.objects(1).flipval = flipvals(i);
    objects{i}.recs.objects(1).class = params.crops_global_info.crops(frame_id).cname;
    objects{i}.recs.objects(1).bbox = [ 1 1 IMAGE_SIZE];
    objects{i}.recs.objects(1).difficult = 0;
end
fprintf('\n');

end

