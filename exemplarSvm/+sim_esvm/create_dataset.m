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
            
            matlab_version = version('-release');
            if (~strcmp(matlab_version(1:4), '2014'))
                objects{i}.I.img = objects{i}.I(:, end:-1:1, :);
            else
                objects{i}.I.img = fliplr(objects{i}.I);
            end
        end

    end
    objects{i}.I.id = frame_id;
    objects{i}.I.flipval = flipvals(i);
    if params.use_cnn_features
        assert(isfield(params, 'features_data'));
        assert(frame_id <= size(params.features_data.features, 1), ...
            'frame_id %d is out of bounds. Max feature index is: %d', frame_id, size(params.features_data.features, 1));
        if ~flipvals(i)
            objects{i}.I.feature = params.features_data.features(frame_id, :)';
            objects{i}.I.feature_flipped = params.features_data.features_flip(frame_id, :)';
        else
            % WARNING: should be ised only for Exemlpars! Negatives must be
            % flipped on-line during running ESVM training.
            % Note: actualy right now we don't support flipped exempalrs.
            assert(false, 'actualy right now we don''t support flipped exempalrs');
            objects{i}.I.feature = params.features_data.features_flip(frame_id, :)';
        end
    end
    
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

