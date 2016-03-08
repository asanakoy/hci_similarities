classdef FeaturesContainer
    %FEATURESCONTAINER Wrapper around matfile. Caches the features from
    % specified category.
    %   Features that are not cached will be loaded from disk.
    
    properties
        file
        is_single_category_file
        category_offset
        category_size
        category_cached_features
        category_cached_features_flip
        is_plain_features
        feature_getter
    end
    
    methods
        function obj = FeaturesContainer(matfile_path, category_offset, category_size, is_single_category_file)
            % Constructor.
            % Params: matfile_path - path to the file with features
            %         category_offset - offset of the category in all dataset
            %         category_size - number of frames in category
            %         is_single_category_file - 1 if matfile contains
            %                                      features for the single
            %                                      category,
            %                                 - 0 if matfiel contains
            %                                     features for all dataset.
            
            if ~exist('is_single_category_file', 'var')
                is_single_category_file = 0;
            end
            file = matfile(matfile_path);
            assert(isprop(file, 'features'));
            assert(isprop(file, 'features_flip'));
            features_size = size(file, 'features');
            
            obj.file = file;
            obj.is_single_category_file = is_single_category_file;
            obj.category_offset = category_offset;
            obj.category_size = category_size;
            
            if is_single_category_file == 0
                first_feature_offset = category_offset;
            else
                assert(features_size(1) == category_size);
                first_feature_offset = 0;
            end
            
            assert(features_size(1) >= first_feature_offset + category_size, ...
                'Features size(%d) is less then first_feature_offset + category_size (%d)', ...
                features_size(1), first_feature_offset + category_size);
            
            fprintf('Caching %d features for category...\n', category_size);
            tic;
            if length(features_size) == 2
                fprintf('.Feature size: %s\n', mat2str(size(file.features(1,:))));
                obj.is_plain_features = 1;
                obj.feature_getter = @(x, frame_ids) (x(frame_ids, :));
                
                obj.category_cached_features{1} = file.features(first_feature_offset + 1: ...
                                                                first_feature_offset + category_size, :);
                obj.category_cached_features{2} = file.features_flip(first_feature_offset + 1: ...
                                                                first_feature_offset + category_size, :);
                                                
            elseif length(features_size) == 4
                obj.is_plain_features = 0;
                fprintf('.Feature size: %s\n', mat2str(size(file.features(1,:, :, :))));
                obj.feature_getter = @(x, frame_ids) (x(frame_ids, :, :, :));
                
                obj.category_cached_features{1} = file.features(first_feature_offset + 1: ...
                                                                first_feature_offset + category_size, :, :, :);
                obj.category_cached_features{2} = file.features_flip(first_feature_offset + 1: ...
                                                                first_feature_offset + category_size, :, :, :);                                            
                
            else
                error('Unknown features matrix size: %s', mat2file(file.features));
            end
            toc
               
        end
        
        
        function feature = get_feature(obj, frame_id, flipval, should_transpose)
            if ~exist('should_transpose', 'var')
                should_transpose = 0;
            end
            assert(flipval == 0 || flipval == 1);
            
            if obj.category_offset < frame_id &&  frame_id <= obj.category_offset + obj.category_size
                feature = obj.feature_getter(obj.category_cached_features{flipval + 1}, frame_id - obj.category_offset);
            else
                fprintf('WARNING! Reading feature from disk.\n');
                feature = read_feature_from_disk(obj, frame_id, flipval);
            end
            feature = squeeze(feature);
            fprintf('Feature size: %s\n', mat2str(size(feature)));
            
            if should_transpose == 1
                num_dimensions = length(size(feature));
                feature = permute(feature, num_dimensions:-1:1);
                fprintf('Transposed feature size: %s\n', mat2str(size(feature)));
            end
        end
        
        
        function feature = read_feature_from_disk(obj, frame_id, flipval)
            if obj.is_single_category_file == 1
                frame_id = frame_id - obj.category_offset;
            end
            
            if flipval == 0
                fild_name = 'features';
            else
                fild_name = 'features_flip';
            end

            if obj.is_plain_features == 1
                feature = obj.file.(fild_name)(frame_id, :);
            else
                feature = obj.file.(fild_name)(frame_id, :, :, :);
            end
        end
    
    end
    
end

