function [score] = sim_esvm_get_score( I, model, params )
% Apply ESVM to the image and get score

if (~exist('params', 'var'))
    params = sim_esvm_get_default_params;
end
%Maximum #windows per exemplar (per image) to keep
params.detect_max_windows_per_exemplar = 1;
%Turn on image flips for detection/training. If enabled, processing
%happes on each image as well as its left-right flipped version.
params.detect_add_flip = 0; % No flipping
params.detect_pyramid_padding = 1; % size of the window shifting
params.detect_keep_threshold = -1e9; % keep all detections

I = im2double(I); % because ESVM lib deals with double images
[resstruct, ~] = esvm_detect(I, model, params);
score = max(resstruct.bbs{1}(:, end));

end

