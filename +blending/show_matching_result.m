function [] = show_matching_result(target_image, i_row, i_col, template_image, target_pad_size)
%SHOW_MATCHING_RESULT Summary of this function goes here
%   Detailed explanation goes here
TARGET_IMAGE_SIZE = [227 + target_pad_size*2, 227 + target_pad_size*2 , 3];
TEMPLATE_SIZE = [227, 227, 3];
assert(all(size(target_image) == TARGET_IMAGE_SIZE));
assert(all(size(template_image) == TEMPLATE_SIZE));
assert(i_row >= 1 && i_row <= TARGET_IMAGE_SIZE(1));
assert(i_col >= 1 && i_col <= TARGET_IMAGE_SIZE(2));

template_padded = padarray(template_image, [target_pad_size, target_pad_size, 0]);
[template_shifted, ~] = blending.get_matched_template(i_row, i_col, template_image, TARGET_IMAGE_SIZE, target_pad_size);

figure;
subplot(1,2,1);
imshow(target_image);
hold on;
him = imshow(template_padded);
set(him,'AlphaData',0.5);
hold off;

subplot(1,2,2);
imshow(target_image);
hold on;
him = imshow(template_shifted);
set(him,'AlphaData',0.5);
hold off;
fprintf('\n');
end

