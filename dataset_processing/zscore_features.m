function zscore_features(input_features_filepath, output_features_filepath)
%Calculate z-scores for the features.

fprintf('Loading features from %s\n', input_features_filepath);
load(input_features_filepath);

fprintf('Calculating z-scores...\n');
features = zscore(features);
features_flip = zscore(features_flip);

fprintf('Saving features to %s\n', output_features_filepath);
save(output_features_filepath, '-v7.3', 'features', 'features_flip');

end

