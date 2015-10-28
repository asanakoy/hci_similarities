function [] = sim_esvm_get_roc( category_name )
%GETROC Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/net/hciserver03/storage/asanakoy/workspace/OlympicSports';
PLOTS_DIR = 'plots';
ESVM_DATA_DRACTION = '0.2';
ESVM_MODELS_DIR_NAME = ['esvm_models_all_' ESVM_DATA_DRACTION];

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end
if ~isfield(data_info, 'dataset_path')
    data_info.dataset_path = dataset_path;
end

% if ~exist('labels_filepath', 'var')
labels_filepath = sprintf(['/net/hciserver03/storage/asanakoy/workspace/'...
                          'dataset_labeling/merged_data_27.10/labels_%s.mat'], category_name);
% end
load(labels_filepath);

%path_labels = ['./labels/labels_',category_name,'.mat'];
path_simMatrix = ['~/workspace/OlympicSports/sim/simMatrix_', category_name, '.mat'];

figure
color = {'r','b'};
model_name = {'HOG-LDA', ['ESVM-' ESVM_DATA_DRACTION]};
NMODELS = 2;

for model_num = 1:NMODELS
    if model_num == 1
        load(path_simMatrix)
    end
    
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
                sprintf('%06d-svm-removed_top_hrd.mat', global_anchor_id))
            
            if ~exist(esvm_model_path, 'file')
                fprintf('WARNING! No model. Skipping label.\n');
                continue;
            end
            
            sims = getEsvmScores(labels(i), category_offset, data_info, esvm_model_path);
            
        end
        
        %check labels with no positives or negatives
        ground_thruth = [true(1, length(labels(i).positives.ids)) false(1, length(labels(i).negatives.ids))];
        %sims = sims/sum(sims);
        
        
        [x{i},y{i}, ~] = perfcurve(ground_thruth, sims, true);
%         if (model_num == 2)
%             x{i} = x{i} + 0.02;
%         end
    end
    
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
end

legend(model_name);
xlabel('False positive rate'); ylabel('True positive rate');
title(strrep(category_name,'_', '-'));
file_base = fullfile(dataset_path, PLOTS_DIR, sprintf('ROC_%s_ESVM-%s_HOG', category_name, ESVM_DATA_DRACTION));
savefig([file_base '.fig']);

fileID = fopen([file_base '.txt'], 'w');
for i = 1:NMODELS
    fprintf(fileID,'%s-auc:\t %d\n', model_name{i}, auc(i));
    fprintf('%s-auc:\t %d\n', model_name{i}, auc(i));
end
fclose(fileID);

end


function scores = getEsvmScores(label, category_offset, data_info, esvm_model_path)
ESVM_CROPS_DIR_NAME = 'crops_227x227';

esvm_file = load(esvm_model_path);

scores = zeros(1, length(label.positives.ids) + length(label.negatives.ids));

ids = [label.positives.ids label.negatives.ids];
flipval = [label.positives.flipval label.negatives.flipval];

for i = 1:length(ids)
    frame_id = category_offset + ids(i);
    
    image_info = get_image_info(frame_id, data_info, ESVM_CROPS_DIR_NAME);
    im = imread(image_info.absolute_path);
    if (flipval(i))
        im = fliplr(im);
    end
    scores(i) = sim_esvm_get_score(im, esvm_file.models(1));
    fprintf('ESVM::Detected img %d, score: %f\n', frame_id, scores(i));
end

end

