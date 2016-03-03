function [ pos_objects, neg_objects ] = create_train_dataset( anchor_ids, anchor_flipvals, params)
%Create train dataset (positives + pool of negatives of other categories)
% Positive objects = achors, defined by anchor_ids
assert(isfield(params, 'positive_category_name'));
assert(isfield(params, 'positive_category_offset'));


pos_objects = sim_esvm.create_dataset(anchor_ids, params, anchor_flipvals);
for i = 1:length(pos_objects)
    if ~strcmp(params.positive_category_name, pos_objects{i}.recs.cname)
        error('Error.\nAll anchors must be from the same category - "%s".\nBut we found - %s!', ...
            params.positive_category_name,  pos_objects{i}.recs.cname);
    end
end

fprintf('Creating negative dataset [Policy: %s]...\n', params.create_negatives_policy);
if length(anchor_ids) > 1 && ...
        (strcmp(params.create_negatives_policy, 'negative_cliques') || ...
         strcmp(params.create_negatives_policy, 'random_from_same_category'))
    error('Negative_cliques creating policy cannot be used for batch of anchors. Only one acnhor is allowed.')
end
    
if strcmp(params.create_negatives_policy, 'negative_cliques')
    negative_ids = negatives_negative_cliques(anchor_ids(1), params);
elseif strcmp(params.create_negatives_policy, 'random_from_same_category')
    negative_ids = negatives_random_from_same_category(anchor_ids(1), params);
else
    negative_ids = negatives_random_from_other_categories(params);
end

neg_objects = sim_esvm.create_dataset(negative_ids, params, false(size(negative_ids)));
fprintf('Done.\n');

end


function [negative_ids] = negatives_negative_cliques(anchor_id, params)
% Take all samples from negative (distant) cliques and use them as negatives.
% Arguments:
%           anchor_id - global id of the positive frame.
%           params - create dataset params
% NOTE: params.cliques_data contains local intra-categorial ids.

    search_index = find(arrayfun(@(x) ...
        x.anchor + params.positive_category_offset == anchor_id, ...
        params.cliques_data.cliques, 'UniformOutput', true));
    assert(length(search_index) == 1);
    
    negative_ids = unique(cell2mat(params.cliques_data.cliques(search_index).negatives.ids));
    negative_ids = negative_ids(:) + params.positive_category_offset; % convert from local to global ids.
    
    % Sanity check, that we don't count anchor frame as negative!
    assert(~ismember(anchor_id, negative_ids), ...
        'The anchor frame belongs to negative clique! Local anchor_id: %d', ...
        anchor_id - params.positive_category_offset);
    negative_ids = setdiff(negative_ids, anchor_id);
    
    assert(~isempty(negative_ids));
end

function [negative_ids] = negatives_random_from_same_category(anchor_id, params)
% Random choose N * params.negatives_train_data_fraction samples from the positive category.
    positive_category_id = find(ismember(params.data_info.categoryNames, params.positive_category_name));

    cat_ids = setdiff(...
        find(params.data_info.categoryLookupTable == positive_category_id), ...
        anchor_id);
    
    cat_length = length(cat_ids);
    cat_subset_idx = randperm(cat_length, ceil(cat_length * params.negatives_train_data_fraction));
    negative_ids = cat_ids(cat_subset_idx);
end

function [negative_ids] = negatives_random_from_other_categories(params)
% Random choose N * params.negatives_train_data_fraction samples from other categories as negatives.
    positive_category_id = find(ismember(params.data_info.categoryNames, params.positive_category_name));
    negative_ids = [];
    for i = 1:length(params.data_info.categoryNames)
        if i == positive_category_id
            continue;
        end
        cat_ids = find(params.data_info.categoryLookupTable == i);
        cat_length = length(cat_ids);
        cat_subset_idx = randperm(cat_length, ceil(cat_length * params.negatives_train_data_fraction));
        negative_ids = [negative_ids cat_ids(cat_subset_idx)];
    end
end