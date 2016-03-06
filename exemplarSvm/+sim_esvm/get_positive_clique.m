function [ positives ] = get_positive_clique(global_anchor_id, create_dataset_params)
% Take all samples from positive clique. Returns global dataset ids.
% Arguments:
%           global_anchor_id - global id of the positive frame.
%           create_dataset_params - create dataset create_dataset_params
% Return:
%        positives.ids -  global id of the frame from positive clique,
%        positives.flipval - their flipvals.
% NOTE: create_dataset_params.cliques_data contains local intra-categorial ids.

search_index = find(arrayfun(@(x) ...
        x.anchor + create_dataset_params.positive_category_offset == global_anchor_id, ...
        create_dataset_params.cliques_data.cliques, 'UniformOutput', true));
assert(length(search_index) == 1);

positives = create_dataset_params.cliques_data.cliques(search_index).positives;
positives.ids = positives.ids + create_dataset_params.positive_category_offset;

positives.flipval = false(size(positives.ids)); % TODO REMOVE!!!

end
