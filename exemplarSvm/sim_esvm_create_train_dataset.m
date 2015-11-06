function [ pos_objects, neg_objects ] = sim_esvm_create_train_dataset( anchor_ids, anchor_flipvals, positive_category_name, ...
                                                                       dataset_path, dataset, data_info, data_fraction)
%Create train dataset (positives + pool of negatives of other categories)
% Positive objects = achors, defined by anchor_ids

% positive_category_name = '';
pos_objects = sim_esvm_create_dataset(anchor_ids, dataset_path, dataset, anchor_flipvals);

for i = 1:length(pos_objects)
%     if i == 1
%         positive_category_name = pos_objects{i}.recs.cname;
%     end
    
    if ~strcmp(positive_category_name, pos_objects{i}.recs.cname)
        error('Error.\nAll anchors must be from the same category - "%s".\nBut we found - %s!', ...
            positive_category_name,  pos_objects{i}.recs.cname);
    end
end

fprintf('Creating negative dataset...\n');
positive_category_id = find(ismember(data_info.categoryNames, positive_category_name));
negative_ids = [];
for i = 1:length(data_info.categoryNames)
    if i == positive_category_id
        continue;
    end
    cat_ids = find(data_info.categoryLookupTable == i);
    cat_length = length(cat_ids);
    cat_subset_idx = randperm(cat_length, ceil(cat_length * data_fraction));
    negative_ids = [negative_ids cat_ids(cat_subset_idx)];
end
% negative_ids = find(data_info.categoryLookupTable ~= positive_category_id);
% negative_ids = negative_ids(randperm(length(negative_ids), 1000)); % GET subset
% negative_ids = negative_ids(1:25000);

neg_objects = sim_esvm_create_dataset(negative_ids, dataset_path, dataset);
fprintf('Done.\n');

end

