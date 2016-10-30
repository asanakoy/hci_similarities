function [] = crop_images()
    src_dir = '/export/home/asanakoy/tmp/NIPS16/cliques/2/';
    img_names = getFilesInDir(src_dir, '.*\.png');
    out_dir = '/export/home/asanakoy/tmp/NIPS16/cliques/2_cropped/';
    
    for name = img_names
       im = imread(fullfile(src_dir, name{:}));
       
       cropped = crop_as(im, [169, 91]);
       imwrite(cropped, fullfile(out_dir, name{:}));
    end
    
end

function [res] = crop_as(what_to_crop, new_size)
% crop bbox with the specific size from the center of the image. 
% Center of the cropped region = center of the image.
% new_size = [height, width]
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