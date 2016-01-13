function [patches] = ecnn_get_random_patches(image)
    assert(size(image, 1) == size(image, 2) && mod(size(image, 1), 2) == 0);
    
    scales = 0.8 .^ [3:-1:0]';
    patch_size = 32;
    NUM_PATCHES = 15;
    
    patches = {};
    
    for i = 1:NUM_PATCHES
        cur_scale = scales(randperm(length(scales), 1));
        cur_size = floor(patch_size / cur_scale); 
        a = randperm(size(image, 1)-cur_size + 1, 1);
        b = randperm(size(image, 2)-cur_size + 1, 1);
        patches{end + 1} = imresize(image(a:a+cur_size-1, b:b+cur_size-1, :), [patch_size patch_size]);

    end
    
        
%     left = int32(1);
%     right = int32(size(image, 1) / 2 + 1);
%     
%     x = {left:right/2, right/2+1:right};
%     y = x;
%     for i = 1:2
%         for j = 1:2
%             a = x{i}(randperm(length(x{i}), 1));
%             b = y{j}(randperm(length(y{j}), 1));
%             patches{end + 1} = imresize(image(a:a+patch_size-1, b:b+patch_size-1, :), [patch_size patch_size]);
%         end
%     end
    
end