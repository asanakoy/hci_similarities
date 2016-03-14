function [ matched_images ] = match_images( images )
%MATCH_IMAGES Summary of this function goes here
%   Detailed explanation goes here
assert(size(images, 4) > 1);
CROP_SIZE = [227, 227 , 3];
matched_images = zeros(size(images), 'uint8');

target_image = images(:, :, :, 1);
matched_images(:, :, :, 1) = target_image;

TARGET_PAD_SIZE = 110;
target_image = padarray(target_image, [TARGET_PAD_SIZE, TARGET_PAD_SIZE, 0], 'replicate');
edge_detection_method = 'canny';
thresh = 0.30;
target_edge_mask = edge(rgb2gray(target_image), edge_detection_method, thresh);
figure;
imshow(target_edge_mask); title('Target edge mask');

target_edge_dist = bwdist(target_edge_mask, 'euclidean');

% figure;
% image(target_edge_dist); title('Target dist mask');

for i = 2:size(images, 4)
    % distance transform and matching 
    template_image = squeeze(images(:, :, :, i));
    temlate_edge_mask = edge(rgb2gray(template_image), edge_detection_method, thresh);
%     figure;
%     imshow(temlate_edge_mask); title(sprintf('Template-%d edges', i));

    map = imfilter(target_edge_dist, double(temlate_edge_mask), 'conv', 'replicate', 'same'); 
%     figure;
%     imagesc(map); title('Detection map');
    
    [min_val, ind] = min(map(:));
    fprintf('Min value: %f\n', min_val);
    [i_row, i_col] = ind2sub(size(map), ind);
    
%     blending.show_matching_result(target_image, i_row, i_col, template_image, TARGET_PAD_SIZE);
    [template_shifted, template_shifted_crop] = blending.get_matched_template(i_row, i_col, template_image, size(target_image), TARGET_PAD_SIZE);
    assert(all(size(template_shifted_crop) == CROP_SIZE));
    matched_images(:, :, :, i) = template_shifted_crop;
end
  

end

