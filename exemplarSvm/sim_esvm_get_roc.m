function [] = sim_esvm_get_roc(category_name, esvm_params)
%GETROC Summary of this function goes here
%   Detailed explanation goes here
addpath(genpath('~/workspace/similarities'))
addpath(genpath('~/workspace/exemplarsvm'))

dataset_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports';
PLOTS_DIR = 'plots';
ESVM_DATA_FRACTION_STR = '0.1';
ROUND_STR = '1';
ESVM_MODELS_DIR_NAME = ['esvm/esvm_models_all_' ESVM_DATA_FRACTION_STR '_round' ROUND_STR];

if ~exist('esvm_params', 'var')
    esvm_params.use_cnn_features = 0;% ESVM Uses CNN features or HOG.
    esvm_params.cnn_features_path = ... % used only if use_cnn_features = 1
        '~/workspace/OlympicSports/alexnet/features/features_all_alexnet_fc7.mat';
    esvm_params.esvm_crops_dir_name = 'crops_227x227';
end

% Load features into memory
if esvm_params.use_cnn_features && ~isfield(esvm_params, 'features_data')
    tic;
    fprintf('Reading CNN features file...\n');
    assert(exist(esvm_params.cnn_features_path, 'file') ~= 0, ...
                'File %s is not found', esvm_params.cnn_features_path);
    esvm_params.features_data = load(esvm_params.cnn_features_path, 'features', 'features_flip');
    toc
end

if ~isfield(esvm_params, 'model_params')
    esvm_params.model_params = sim_esvm_get_default_params;
    if esvm_params.use_cnn_features
        esvm_params.model_params.features_type = 'FeatureVector';
        ESVM_MODELS_DIR_NAME = 'esvm/alexnet_esvm_models_long_jump';
    else
        esvm_params.model_params.features_type = 'HOG-like';
    end
end


if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end
if ~isfield(data_info, 'dataset_path')
    data_info.dataset_path = dataset_path;
end

% if ~exist('labels_filepath', 'var')
labels_filepath = sprintf(['/net/hciserver03/storage/asanakoy/workspace/'...
                          'dataset_labeling/merged_data_19.02.16/labels_%s.mat'], category_name);
% end
load(labels_filepath);

%path_labels = ['./labels/labels_',category_name,'.mat'];
path_simMatrix = ['~/workspace/OlympicSports/sim/simMatrix_', category_name, '.mat'];

figure
color = {'r','b'};
model_name = {'HOG-LDA', ['ESVM-' ESVM_DATA_FRACTION_STR '-R' ROUND_STR '-nocut']};
% model_name = {'HOG-LDA', ['ESVM-' ESVM_DATA_FRACTION_STR '-R' ROUND_STR]}
NMODELS = 2;
sims_esvm = {};

for model_num = 1:NMODELS
    if model_num == 1
        load(path_simMatrix)
    end
    
    mean_x = [];
    mean_y = [];
    x = {};
    y = {};
    
    for i = 1:length(labels)
        
        if (length(labels(i).positives.ids)<1) || (length(labels(i).negatives.ids)<1)
            continue
        end
        
        if model_num == 1
            
            sims = simMatrix(labels(i).anchor,[labels(i).positives.ids,labels(i).negatives.ids]);
%             figure();
%             showImage(category_offset + labels(i).anchor, dataset_path, ...
%                 data_info.sequenceFilesPathes, data_info.sequenceLookupTable, ...
%                 sprintf('Anchor %d', i), 0);
            
        else
            global_anchor_id = category_offset + labels(i).anchor;
            esvm_model_path = fullfile(data_info.dataset_path, ...
                ESVM_MODELS_DIR_NAME, sprintf('%06d', global_anchor_id), ...
                                sprintf('%06d-svm.mat', global_anchor_id));
%                 sprintf('%06d-svm-removed_top_hrd.mat', global_anchor_id))



            
            if ~exist(esvm_model_path, 'file')
                fprintf('WARNING! No model %s. Skipping label.\n', esvm_model_path);
                sims = []
                continue;
            end
            
            sims = getEsvmScores(labels(i), category_offset, data_info, esvm_model_path, esvm_params);
            sims_esvm{i} = sims;
            
        end
        
        %check labels with no positives or negatives
        ground_thruth = [true(1, length(labels(i).positives.ids)) false(1, length(labels(i).negatives.ids))];
        %sims = sims/sum(sims);
        
        
        [x{i},y{i}, ~] = perfcurve(ground_thruth, sims, true);
%         if (model_num == 2)
%             x{i} = x{i} + 0.02;
%         end
    end
    if ~isempty(x)
        mean_x = linspace(0, 1, 100);
        for i = 1:length(x)
            if length(x{i}) < 1
                continue
            end
            [new_x, idx] = unique(x{i});
            mean_y(i,:) = interp1(new_x, y{i}(idx), mean_x);
        end

        plot(mean_x, mean(mean_y, 1), color{model_num})
        auc(model_num) = trapz(mean_x, mean(mean_y, 1));
        hold on
    else
        auc(model_num) = 0.0;
    end
end

legend(model_name);
xlabel('False positive rate'); ylabel('True positive rate');
title(strrep(category_name,'_', '-'));
file_base = fullfile(dataset_path, PLOTS_DIR, sprintf('ROC_%s_%s_%s', ...
                     category_name, model_name{1}, model_name{2}));
savefig([file_base '.fig']);

fileID = fopen([file_base '.txt'], 'w');
for i = 1:NMODELS
    fprintf(fileID,'%s-auc:\t %d\n', model_name{i}, auc(i));
    fprintf('%s-auc:\t %d\n', model_name{i}, auc(i));
end
fclose(fileID);

save(fullfile(dataset_path, PLOTS_DIR, sprintf('sims_%s_%s.mat', ...
                     category_name, model_name{2})), 'sims_esvm');

end


function scores = getEsvmScores(label, category_offset, data_info, esvm_model_path, esvm_params)
esvm_file = load(esvm_model_path);

scores = zeros(1, length(label.positives.ids) + length(label.negatives.ids));

ids = [label.positives.ids label.negatives.ids];
flipval = [label.positives.flipval label.negatives.flipval];

for i = 1:length(ids)
    frame_id = category_offset + ids(i);
    
    sample = createEsvmSample(frame_id, flipval(i), data_info, esvm_params);
   
    scores(i) = sim_esvm_get_score(sample, esvm_file.models(1), esvm_params.model_params);
    fprintf('ESVM::Detected img %d, score: %f\n', frame_id, scores(i));
end

end

function sample = createEsvmSample(frame_id, flipval, data_info, esvm_params)
% If use_cnn_features == 1 return ImageStruct.
%   ImageStruct fields:
%                       id - image id,
%                       flipval - 1 if it is flipped, 0 - otherwise, 
%                       feature - feature representation of the
%                                           image.
%
% If use_cnn_features == 0 return RGB image.

    if esvm_params.use_cnn_features == 0
        image_info = get_image_info(frame_id, data_info, esvm_params.esvm_crops_dir_name);
        im = imread(image_info.absolute_path);
        if flipval
            im = fliplr(im);
        end
        sample = im;
    else
        sample.id = frame_id;
        if ~flipval
            sample.feature = esvm_params.features_data.features(frame_id, :)';
        else
            sample.feature = esvm_params.features_data.features_flip(frame_id, :)';
        end
    end
end
