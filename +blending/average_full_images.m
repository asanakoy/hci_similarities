function [] = average_full_images(model, category_name, anchor_id, num_nns)
%AVERAGE_FULL_IMAGES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '~/workspace/OlympicSports';
crops_dir = fullfile(dataset_path, 'crops');
clips_dir = fullfile(dataset_path, 'clips');

[nns, flips] = blending.get_nns(model, category_name, anchor_id, num_nns);
fprintf('%s\n', mat2str(nns(1:10)));
fprintf('nns: %d\n', length(nns));
[res_1, res_2] = blending.average_crops(category_name, anchor_id, nns, flips);
% original crop will be situated in the center of the res image
% close;
% imwrite(res_1, sprintf('~/tmp/NIPS16/cliques/%s_%d_%s_%dnns_parts.png', category_name, anchor_id, model, num_nns), 'png');
% imwrite(res_2, sprintf('~/tmp/NIPS16/cliques/%s_%d_%s_%dnns_linavg.png', category_name, anchor_id, model, num_nns), 'png');

% return;

data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
crops_info = load(fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info_with_bboxes.mat'));
offset = get_category_offset(category_name, data_info);

anchor_crop_path = fullfile(crops_dir, crops_info.crops(offset + anchor_id).img_relative_path);
anchor_crop = imread(anchor_crop_path);

res = res_2;

[bg, mid_h, mid_w] = average_bg(crops_info, crops_dir, clips_dir, offset, nns, flips);
figure;
imshow(bg);
title('bg');
imwrite(bg, sprintf('~/tmp/NIPS16/%s_%d_%s_bg.png', category_name, anchor_id, model), 'png');
imwrite(res, sprintf('~/tmp/NIPS16/%s_%d_%s_crop.png', category_name, anchor_id, model), 'png');


cropped_res = res;%crop_as(res, size(anchor_crop) - 10);
% figure;
% imshow(cropped_res);
% title('cropped res');

res_crop_padded = bg;
res_crop_padded = write_to_mid(cropped_res, res_crop_padded, mid_h, mid_w);

% figure;
% imshow(res_crop_padded);
% title('bg + res cropped');

interp = res_crop_padded;
for i = 2:size(res_crop_padded, 1) - 1
    for j = 2:size(res_crop_padded, 2) - 1
        if (all(interp(i, j, :) < 48))
            interp(i, j, :) =  bg(i, j, :);%lin_interp(res_crop_padded, i, j);
        end
    end
end

% figure;
% imshow(interp);
% title('lin interp');

BW = im2bw(res_crop_padded, 0.30);
% imshow(BW);
edges = imdilate(BW, strel('square', 3));
edges = imerode(edges, strel('square', 15));

% interp_gauss = interp;
% for i = 1:10
% gauss_filter = fspecial('gaussian',[5 5], 5);
% interp_gauss = imfilter(interp_gauss, gauss_filter, 'same');
% end

% figure;
% imshow(interp_gauss);
% title('interp + gauss');

mask = ~edges;

Inew = interp .* uint8(repmat(~mask, [1,1,3])) + bg .* uint8(repmat(mask, [1,1,3]));
Inew = uint8(Inew);

Inew = write_to_mid(crop_as(res, size(anchor_crop) - 30), Inew, mid_h, mid_w);

figure;
imshow(Inew);
title('RESULT')
imwrite(Inew, sprintf('~/tmp/NIPS16/%s_%d_%s.png', category_name, anchor_id, model), 'png');

anchior_frame_path = fullfile(clips_dir, crops_info.crops(offset + anchor_id).img_relative_path);
anchior_frame_path = [anchior_frame_path(1:end-3), 'jpg'];

anchor_full_frame = imread(anchior_frame_path);
crop_size = size(anchor_crop);
anchor_box = crops_info.crops(offset + anchor_id).bbox;
anchor_box = anchor_box([2, 1, 4, 3]); % [rows, cols] format for the points
scale = crop_size(1) /  (anchor_box(3) - anchor_box(1));
assert (abs(scale - crop_size(2) /  (anchor_box(4) - anchor_box(2))) < 0.2, ...
    sprintf('%f', abs(scale - crop_size(2) /  (anchor_box(4) - anchor_box(2)))));

anchor_full_frame_resized = imresize(anchor_full_frame, scale, 'bicubic');
imwrite(anchor_full_frame_resized, sprintf('~/tmp/NIPS16/%s_%d_%s.png', category_name, anchor_id, 'ANCHOR'), 'png'); 
    
% 
% alpha = 0.3;
% res = double(bg) * alpha + (1 - alpha) * double(res_crop_padded);
% 
% res = uint8(res);
% 
% figure;
% subplot(1,2,1);
% imshow(bg);
% 
% subplot(1,2,2);
% imshow(res);


end


function [result] = write_to_mid(part, destination, mid_h, mid_w)

box = size(part);
left = round(box(2) / 2);
right = box(2) - left;
up = round(box(1) / 2);
down = box(1) - up;

destination(mid_h - up + 1:mid_h + down, mid_w - left + 1:mid_w + right, :) = part;
result = destination;
end

function pix = lin_interp(im, i, j)
pix = zeros(1, 1, 3);
for x = [-1, 0, 1]
    for y = [-1, 0, 1]
        if x == y
            continue;
        end
        pix = pix + double(im(i + x, j + y, :));
    end
end
pix = round(pix / 8);
end

function [res] = crop_as(what_to_crop, new_size)
% crop bbox with the specific size from the center of the image. 
% Center of the cropped region = center of the image. 
    to_left = round(new_size(2) / 2);
    to_right = new_size(2) - to_left;
    to_up = round(new_size(1) / 2);
    to_down = new_size(1) - to_up;
    
    res_mid_h = round(size(what_to_crop, 1) / 2);
    res_mid_w = round(size(what_to_crop, 2) / 2);
    
    assert(res_mid_h - to_up + 1 >= 1);
    assert(res_mid_h + to_down <= size(what_to_crop, 1));
    assert(res_mid_w - to_left + 1 >= 1);
    assert(res_mid_w + to_right <= size(what_to_crop, 2));
    
    res = what_to_crop(res_mid_h - to_up + 1:res_mid_h + to_down, res_mid_w - to_left + 1:res_mid_w + to_right, :);
end


function [avg, mid_h, mid_w] = average_bg(crops_info, crops_dir, clips_dir, category_offset, nns, flipvals)

sizes = zeros(length(nns), 2);
box_centers = zeros(length(nns), 2);

left  = zeros(length(nns), 1);
right = zeros(length(nns), 1);
up = zeros(length(nns), 1);
down = zeros(length(nns), 1);

for i = 1:length(nns)
    crops_path = fullfile(crops_dir, crops_info.crops(category_offset + nns(i)).img_relative_path);
    crop_size = size(imread(crops_path));
    crop_size = crop_size(1:2);
    
    frame_path = fullfile(clips_dir, crops_info.crops(category_offset + nns(i)).img_relative_path);
    frame_path = [frame_path(1:end-3), 'jpg'];
    frames{i} = double(imread(frame_path));
    if flipvals(i)
        frames{i} = fliplr( frames{i});
    end
    
    box = crops_info.crops(category_offset + nns(i)).bbox;
    box = box([2, 1, 4, 3]); % [rows, cols] format for the points
    scale = crop_size(1) /  (box(3) - box(1));
    assert (abs(scale - crop_size(2) /  (box(4) - box(2))) < 0.2, ...
        sprintf('%f', abs(scale - crop_size(2) /  (box(4) - box(2)))));
    
    box = box * scale;
    frames{i} = imresize(frames{i}, scale, 'bicubic');
    sz = size(frames{i});
    sizes(i, :) = sz(1:2);
    
    box_centers(i, :) = round((box(1:2) + box(3:4))  / 2.0);
    
    left(i) = box_centers(i, 2);
    right(i) = sizes(i, 2) - box_centers(i, 2);
    up(i) = box_centers(i, 1);
    down(i) = sizes(i, 1) -  box_centers(i, 1);
    
%     figure;
%     imshow(uint8(frames{i}));
%     pause(1);
    
end

h = max(up) + max(down);
w = max(left) + max(right);

mid_h = max(up);
mid_w = max(left);

avg = zeros(h, w, 3, 'double');
fprintf('Size avg: %s\n', mat2str(size(avg)));

for i = 1:length(nns)
    prev = avg(mid_h - up(i) + 1:mid_h + down(i), mid_w - left(i) + 1: mid_w + right(i), :);
    avg(mid_h - up(i) + 1:mid_h + down(i), mid_w - left(i) + 1: mid_w + right(i), :) = prev + frames{i};
end

avg = uint8(avg / length(nns));

end