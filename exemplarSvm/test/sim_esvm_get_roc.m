function [result] = sim_esvm_get_roc(category_name, roc_params)
%GETROC Plot ROC curve and calculate AUC.

if ~exist('roc_params', 'var')
    roc_params = get_roc_params(category_name);
end

dataset_path = roc_params.dataset_path;
load(roc_params.labels_filepath);

if ~isfield(roc_params, 'models_to_test')
    model_name = {'ESVM', 'SIM'};
else
    model_name = roc_params.models_to_test;
end
ESVM_MODEL_INDEX = find(cellfun(@(x) strncmpi(x, 'ESVM', 3), model_name));
SIM_MATRIX_MODEL_INDEX = find(cellfun(@(x) strncmpi(x, 'SIM', 3), model_name));
CORR_INDEX  = find(cellfun(@(x) strcmp(x, 'corr'), model_name));

color = {'r','b'};
figure

NMODELS = length(model_name);
sims_esvm = {};

for model_num = 1:NMODELS
    if model_num == SIM_MATRIX_MODEL_INDEX
        load(roc_params.path_simMatrix)
    end
    
    mean_x = [];
    mean_y = [];
    x = {};
    y = {};
    
    for i = 1:length(labels)
        
        if (length(labels(i).positives.ids)<1) || (length(labels(i).negatives.ids)<1)
            continue
        end
        
        if model_num == SIM_MATRIX_MODEL_INDEX
            assert(exist('simMatrix_flipped', 'var') || exist('simMatrix_flip', 'var'));
            if ~exist('simMatrix_flipped', 'var')
                simMatrix_flipped = simMatrix_flip;
            end
            sims = getScoresFromSimMatrix(labels(i), simMatrix, simMatrix_flipped);
%             sims = simMatrix(labels(i).anchor, [labels(i).positives.ids,labels(i).negatives.ids]);
%             figure();
%             showImage(category_offset + labels(i).anchor, dataset_path, ...
%                 roc_params.data_info.sequenceFilesPathes, roc_params.data_info.sequenceLookupTable, ...
%                 sprintf('Anchor %d', i), 0);
            
        elseif model_num == ESVM_MODEL_INDEX
            global_anchor_id = category_offset + labels(i).anchor;
            if roc_params.use_models_with_top_hardest_negatives_removed == 0
                model_name_format_str = '%06d-svm.mat';
            else
                model_name_format_str = '%06d-svm-removed_top_hrd.mat';
            end
            esvm_model_path = fullfile(...
                roc_params.esvm_models_dir, sprintf('%06d', global_anchor_id), ...
                                sprintf(model_name_format_str, global_anchor_id));

            
            if ~exist(esvm_model_path, 'file')
                fprintf('WARNING! No model %s. Skipping label.\n', esvm_model_path);
                sims = []
                continue;
            end
            
            sims = getScores(global_anchor_id, labels(i), category_offset, esvm_model_path, roc_params, 'esvm');
            sims_esvm{i} = sims;
        elseif model_num == CORR_INDEX
            global_anchor_id = category_offset + labels(i).anchor;
            sims = getScores(global_anchor_id, labels(i), category_offset, '', roc_params, 'corr');
        else
            error('Unknown model!');
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
fprintf('Number of anchor frames: %d\n', length(labels));

roc_params

models_str = '';
for i = 1:NMODELS
    models_str = strcat(models_str, '_', model_name{i});
end

file_base = fullfile(dataset_path, roc_params.plots_dir, sprintf('ROC_%s%s', ...
                     category_name, models_str));
                 
fileID = fopen([file_base '.txt'], 'w');
for i = 1:NMODELS
    fprintf(fileID,'%s-auc:\t %.4f\n', model_name{i}, auc(i));
    fprintf('%s-auc:\t %.4f\n', model_name{i}, auc(i));
    
    result(i).auc = auc(i);
    result(i).model_name = model_name{i};
    
end
fclose(fileID);

save_figure(gcf, file_base);
if (ESVM_MODEL_INDEX)
    save(fullfile(dataset_path, roc_params.plots_dir, sprintf('sims_%s_%s.mat', ...
                     category_name, roc_params.esvm_name)), 'sims_esvm');
end

end

function scores = getScoresFromSimMatrix(label, simMatrix, simMatrix_flipped)
% Get scores for the similarity matrix.

scores = zeros(1, length(label.positives.ids) + length(label.negatives.ids));

ids = [label.positives.ids label.negatives.ids];
flipval = [label.positives.flipval label.negatives.flipval];

for i = 1:length(ids)
    frame_id = ids(i);
    
    if ~flipval(i)
        scores(i) = simMatrix(label.anchor, frame_id);
    else
        scores(i) = simMatrix_flipped(label.anchor, frame_id);
    end
end

end

function scores = getScores(anchor_id, label, category_offset, esvm_model_path, roc_params, method)
% Get scores for the labeled frames.
% method: ['esvm', 'corr']

if strcmp(method, 'esvm')
    esvm_file = load(esvm_model_path);
end

scores = zeros(1, length(label.positives.ids) + length(label.negatives.ids));

ids = [label.positives.ids label.negatives.ids];
flipval = [label.positives.flipval label.negatives.flipval];

for i = 1:length(ids)
    frame_id = category_offset + ids(i);
    
    if strcmp(method, 'esvm')
        sample = createEsvmSample(frame_id, flipval(i), roc_params);
        scores(i) = sim_esvm.detection.get_score(sample, esvm_file.models(1), roc_params.detect_params);
    elseif strcmp(method, 'corr')
        scores(i) = get_correlation(frame_id, flipval(i), anchor_id, 0, roc_params);
    else
        error('Unknown type!');
    end
    
    fprintf('Detected img %d, score: %f\n', frame_id, scores(i));
end

end

function score = get_correlation(frame_id1, flipval1, frame_id2, flipval2, roc_params)
% Calculate Pearson correlation between 2 feature vectors of specified frames.
    assert(roc_params.should_load_features_from_disk == 1);
    a = createEsvmSample(frame_id1, flipval1, roc_params);
    b = createEsvmSample(frame_id2, flipval2, roc_params);
    
    score = 2 - pdist2(a.feature(:)', b.feature(:)', 'correlation'); 
end

function sample = createEsvmSample(frame_id, flipval, roc_params)
% If use_plain_features == 1 return ImageStruct.
%   ImageStruct fields:
%                       id - image id,
%                       flipval - 1 if it is flipped, 0 - otherwise, 
%                       feature - feature representation of the
%                                           image.
%
% If use_plain_features == 0 return RGB image.

    if roc_params.should_load_features_from_disk == 0
        if roc_params.should_use_crops_info == 1
            image_path = fullfile(roc_params.dataset_path, ...
                roc_params.esvm_crops_dir_name, ...
                roc_params.crops_info.crops(frame_id).img_relative_path);
        else
            image_info = get_image_info(frame_id, roc_params.data_info, roc_params.esvm_crops_dir_name);
            image_path = image_info.absolute_path;
        end
        im = imread(image_path);
        if flipval
            im = utils.fliplr(im);
        end
        sample = im;
    else
        sample.id = frame_id;
        sample.feature = roc_params.features_data.get_feature(frame_id, flipval, roc_params.use_plain_features);
    end
end

function save_figure(fig, file_base)
    matlab_version = version('-release');
    if str2num(matlab_version(1:4)) < 2013
        saveas(fig, [file_base '.fig']); % for Matlab < 2013 
    else
        savefig(fig, [file_base '.fig']);
    end
end
