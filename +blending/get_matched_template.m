function [ template_shifted, template_shifted_crop] = get_matched_template(i_row, i_col, ...
    template_image, TARGET_IMAGE_SIZE, target_pad_size)
%GET_SHIFTED_IMAGE Summary of this function goes here
%   Detailed explanation goes here

template_size = size(template_image);
assert(i_row >= 1 && i_row <= TARGET_IMAGE_SIZE(1));
assert(i_col >= 1 && i_col <= TARGET_IMAGE_SIZE(2));

offset = [i_row - floor(template_size(1) / 2), i_col - floor(template_size(2) / 2)];
template_mask = false(TARGET_IMAGE_SIZE(1), TARGET_IMAGE_SIZE(2));
template_mask(offset(1):offset(1) + template_size(1) - 1, offset(2):offset(2) + template_size(2) - 1) = 1;

template_shifted = zeros(TARGET_IMAGE_SIZE, 'uint8');
[r, c] = find(template_mask);
template_shifted(min(r):max(r), min(c):max(c), :) = template_image;
template_shifted_crop = template_shifted(target_pad_size + 1: target_pad_size + 227,...
                                         target_pad_size + 1: target_pad_size + 227, :);

end

