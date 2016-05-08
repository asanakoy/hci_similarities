function [] = get_roc_by_scores(scores, labels)
%GETROC Plot ROC curve and calculate AUC.
assert(length(scores) == length(labels));

area = [];
mean_x = [];
mean_y = [];
x = {};
y = {};

for i = 1:length(labels)

    if (length(labels(i).positives.ids)<1) || (length(labels(i).negatives.ids)<1)
        continue
    end

    anchor_id = labels(i).anchor;
    sims = scores{i};

    %check labels with no positives or negatives
    ground_thruth = [true(1, length(labels(i).positives.ids)), false(1, length(labels(i).negatives.ids))];

    [x{i},y{i}, ~, area(i)] = perfcurve(ground_thruth, sims, true);
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

    plot(mean_x, mean(mean_y, 1), 'r')
    auc = trapz(mean_x, mean(mean_y, 1));
    hold on
else
    auc = 0.0;
end

fprintf('ROC AUC: %f\n', auc);


legend('ROC');
xlabel('False positive rate'); ylabel('True positive rate');
title(strrep(category_name,'_', '-'));
fprintf('Number of anchor frames: %d\n', length(labels));

end
