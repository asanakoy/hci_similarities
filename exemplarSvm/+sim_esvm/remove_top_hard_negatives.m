function [models] = remove_top_hardest_negatives(models, neg_set, esvm_train_params)
% Remove the hardest negatives from model and retrain.
% Save resultant model on disk.

    PART_OF_NEGATIVES_TO_REMOVE = esvm_train_params.remove_top_hard_negatives_fraction;
    fprintf('Dropping %f%% of the top hardest negatives...\n', PART_OF_NEGATIVES_TO_REMOVE * 100);
    for i = 1:length(models)
        scores = models{i}.model.w(:)' * models{i}.model.svxs - models{i}.model.b;
        [~, idx] = sort(scores,'descend');
        new_start = ceil(PART_OF_NEGATIVES_TO_REMOVE * length(idx));
        idx = idx(new_start:end);
        models{i}.model.svxs = models{i}.model.svxs(:,idx);
        
        if esvm_train_params.use_negative_mining == 0
            models{i} = esvm_train_svm_at_once(models{i}, models{i}.model.svxs);
        else
            models{i}.model.svbbs = models{i}.model.svbbs(idx,:);

            models{i} = esvm_update_svm(models{i});
            cur_iter = models{i}.iteration + 1;
            models{i}.iteration = cur_iter;  
            models{i}.mining_stats{cur_iter}.num_epty = 0;
            models{i}.mining_stats{cur_iter}.num_violating = 0;
            models{i}.mining_stats{cur_iter}.total_mines = 0;
            models{i}.mining_stats{cur_iter}.comment = sprintf('cutted_%.2f_top_hard_neg', PART_OF_NEGATIVES_TO_REMOVE);
        end
        
        if models{1}.mining_params.dump_images == 1
            esvm_dump_figures(models{i}, neg_set);
        end
    end
        filer2 = fullfile(models{i}.dataset_params.localdir, [models{i}.models_name '-removed_top_hrd.mat']);
%         %Save the result
        savem(filer2, models{i});
end

function savem(filer2, models) %#ok<INUSD>
    save(filer2, 'models');
end