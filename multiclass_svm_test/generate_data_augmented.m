function [ data ] = generate_data_augmented( settings, data_filepath )
% Generate dataset for SVM using images and labels, stored in mat file

validateattributes(settings, {'MulticlassSvmSettings'}, {'scalar'});

IMAGE_SIZE = [227 227];
ESVM_NUMBER_OF_WORKERS = 2;

file = load(data_filepath);

data.X = [];
data.y = file.new_labels' + 1; % labels start from 0

fprintf('Loading esvm models...\n');
basis_models = load_basis_esvm_models(settings.basis_models_handles, settings.get_esvm_models_path());


n_images = size(file.new_images, 4);

X = zeros(n_images, length(basis_models));
dataset_images = file.new_images;

% str = sprintf('%05d/%05d', 0, n_images);
% str_width = length(str);
% clean_symbols = repmat('\b', 1, str_width);

p = gcp('nocreate'); % If no pool, then create a new one.
if isempty(p)
    fprintf('Starting parpool with %d workers...\n', ESVM_NUMBER_OF_WORKERS);
    c = parcluster('local');
    c.NumWorkers = ESVM_NUMBER_OF_WORKERS;
    
    if (~strcmp(version('-release'), '2014b'))
        matlabpool(c, c.NumWorkers);
    else
        parpool(c, c.NumWorkers);
    end 
end


% fprintf('Calculating scores for image: %s', str);
fprintf('Calculating scores for images...\n');
k = 0;
parfor i = 1:n_images
%     fprintf(clean_symbols);

    
    image = imresize(dataset_images(:, :, :, i), IMAGE_SIZE);
    features = get_feature_vector(image, basis_models);
    X(i, :) = features;
    k = k + 1;
    
    if (~mod(1, 1000))
            fprintf('%05d/%05d\n', ki, n_images);
    end
end
fprintf('\n');
fprintf('Total %d images\n', k);

data.X = X;

end


function [features] = get_feature_vector(image, basis_models)
    
    features = zeros(1, length(basis_models));
    for i = 1:length(basis_models)
        features(i) = sim_esvm_get_score(image, basis_models{i});
    end
end
