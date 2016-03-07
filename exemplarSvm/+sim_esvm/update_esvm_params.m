function [ esvm_params ] = update_esvm_params( esvm_params, train_params )
% Update parameters (esvm_params) that will be passed to ESVM-lib with the values from
% train parameters (train_params).

esvm_params.train_svm_c = train_params.train_svm_c;
esvm_params.positive_class_svm_weight = train_params.positive_class_svm_weight;
esvm_params.auto_weight_svm_classes = train_params.auto_weight_svm_classes;

esvm_params.should_load_features_from_disk = train_params.should_load_features_from_disk;
esvm_params.init_params.should_load_features_from_disk = train_params.should_load_features_from_disk;

esvm_params.detect_pyramid_padding = train_params.detect_padding;

esvm_params.restore_hog_lost_bin = train_params.restore_hog_lost_bin;
esvm_params.init_params.restore_hog_lost_bin = train_params.restore_hog_lost_bin;

if train_params.use_plain_features
    esvm_params.features_type = 'FeatureVector';
    esvm_params.init_params.features_type = esvm_params.features_type;
    esvm_params.init_params.features = @sim_esvm.cnnfeatures; % NOTE: Not used now. Features are precomputed. 
    esvm_params.dataset_params.display = 0; % display is not implemented for FeatureVector
    esvm_params.dump_images = 0; % dump_images is not implemented for FeatureVector
end

assert(train_params.should_load_features_from_disk == 1 || train_params.use_plain_features == 0, ...
        'Online calculation of plain features is not implemented!')
assert(esvm_params.auto_weight_svm_classes == 0 || train_params.use_negative_mining == 1, ...
    'auto_weight_svm_classes not implemented for training at once!'); % TODO: implement for 'at once'.

end

