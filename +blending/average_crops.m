function [res_1, res_2] = average_crops(categ, anchor_frame, frames2average, fliplvals)   

frame_info = load(sprintf('~/workspace/similarities/+blending/frame_info/frame_info_%s.mat', categ), 'frame_info');
frame_info = frame_info.frame_info;

main_dir = pwd;
path_base_images = ['/export/home/asanakoy/workspace/OlympicSports/crops/', categ, '/'];
show_edges = 0;

%get dist_mat and frame_info
% path_distMat_NNSets = sprintf('../ActionRecognition_Memex/Similarities_NNSets/%s/DISTANCE_MAT.mat', categ);
% DISTANCE_MAT = [];
% load(path_distMat_NNSets);
% dist_mat = DISTANCE_MAT.dist_mat;
% dist_mat = (dist_mat + dist_mat) / 2';   %symmetrize dist-mat
% frame_info = DISTANCE_MAT.frame_info;

%get original flip mat
% path_distMat = ...
%     sprintf('../ActionRecognition_Memex/Similarities_whiteLDA/%s/%s/FLIP_MAT.mat', categ, categ);
% load(path_distMat);
% flip_mat = FLIP_MAT;

%get videonames
videonames = dir(path_base_images);
idx = arrayfun(@(x)x.name(1)=='.',videonames);
videonames(idx) = [];
                            
%initialize contour model
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory
model_edge=edgesTrain(opts); % will load model if already trained
model_edge.opts.multiscale=0;          % for top accuracy set multiscale=1
model_edge.opts.sharpen=2;             % for top speed set sharpen=0
model_edge.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model_edge.opts.nThreads=4;            % max number threads for evaluation
model_edge.opts.nms=0;                 % set to true to enable nms
 
th_E = 0.6; %0.3
highthr = 0.2;  %0.2
lowthr = 0.05;

%add anchor frame to average frame set
% frames2average = cat(1, anchor_frame, frames2average);
    
%----------------------------%
% load images and save sizes %
%----------------------------%

frames_tmp = cell(length(frames2average), 1);
frame_size = zeros(length(frames2average), 3);
for j = 1:length(frames2average)

    seq_id = frame_info(frames2average(j), 2);
    frame_id = frame_info(frames2average(j), 3);

    %load frames
    seq = dir([path_base_images, videonames(seq_id).name]);
    idx = arrayfun(@(x)x.name(1)=='.',seq);
    seq(idx) = [];

    im = imread(sprintf('/export/home/asanakoy/workspace/OlympicSports/crops/%s/%s/%s', ...
        categ, videonames(seq_id).name, seq(frame_id).name));  

    %flip image if needed
    if fliplvals(j) == 1
        im = fliplr(im);
    end

    frames_tmp{j} = im;
    frame_size(j, :) = size(im);        
end

%------------------------------------%
% Compute Edge image of anchor frame %
%------------------------------------%

%anchor frame
seq_id = frame_info(anchor_frame, 2);
frame_id = frame_info(anchor_frame, 3);

seq = dir([path_base_images, videonames(seq_id).name]);
idx = arrayfun(@(x)x.name(1)=='.',seq);
seq(idx) = [];

im_orig = imread(sprintf('/export/home/asanakoy/workspace/OlympicSports/crops/%s/%s/%s', ...
        categ, videonames(seq_id).name, seq(frame_id).name));

%add anchor frame size to frame_size and compute max frame size
frame_size(end+1, :) = size(im_orig);    
max_frame_w = max(frame_size(:,2));
mid_frame_w = floor(max_frame_w / 2) + 1;
max_frame_h = max(frame_size(:,1));
mid_frame_h = floor(max_frame_h / 2) + 1;

%zero padding
[h, w, d] = size(im_orig);          
im_pad = zeros(max_frame_h, max_frame_w, 3);
im_pad(mid_frame_h - floor(h/2):mid_frame_h - floor(h/2) + h - 1,...
    mid_frame_w - floor(w/2):mid_frame_w - floor(w/2) + w - 1, :) = im_orig;  
im_pad = uint8(im_pad);

%get edge image - Canny
%     E_im = double(edge(rgb2gray(im_pad), 'canny', [lowthr, highthr]));
%     se = strel('disk', 1);
%     E_im = imdilate(E_im, se);

%get edge image - Other
[E_im,~,~,~]=edgesDetect(im_pad, model_edge);
E_im(E_im>highthr) = highthr;
E_im(E_im<lowthr) = lowthr;
E_im = 1/highthr * E_im;
E_im(E_im < th_E) = 0;

%Thinnening
radius = 10;
thr = 0.05;  
[subs1,vals1] = nonMaxSupr(double(E_im), radius);
bw1nms = zeros(size(E_im));
bw1nms(sub2ind(size(bw1nms),subs1(:,1),subs1(:,2))) =...
    E_im(sub2ind(size(bw1nms),subs1(:,1),subs1(:,2)));
E_im = double(bw1nms);    

%remove edges due to zero padding
E_im(1:mid_frame_h - floor(h/2) - 1, :) = 0;
E_im(mid_frame_h - floor(h/2) + h - 2:end, :) = 0;
E_im(:, 1:mid_frame_w - floor(w/2)+1) = 0;
E_im(:, mid_frame_w - floor(w/2) + w - 2:end) = 0;

E_im(E_im < th_E) = 0;
E_im(E_im >= th_E) = 1;
E_imOrig_distTrafo = -bwdist(E_im);
E_imOrig_distTrafo = E_imOrig_distTrafo + max(abs(E_imOrig_distTrafo(:)));

%enlarge distance transfo by border extension
border_ext_h = 10;
border_ext_w = 20;
E_im_ext =...
zeros(size(E_im, 1) + border_ext_h,...
size(E_im, 2) + border_ext_w);

max_frame_w2 = size(E_im_ext,2);
mid_frame_w2 = floor(max_frame_w2 / 2) + 1;
max_frame_h2 = size(E_im_ext,1);
mid_frame_h2 = floor(max_frame_h2 / 2) + 1;

[h, w] = size(E_im);          
E_im_ext(mid_frame_h2 - floor(h/2):mid_frame_h2 - floor(h/2) + h - 1,...
    mid_frame_w2 - floor(w/2):mid_frame_w2 - floor(w/2) + w - 1) = E_im;  
E_im_ext = uint8(E_im_ext);

if show_edges
    figure(2); imshow(E_im);
end

%binarization & distance transformation
E_im_ext(E_im_ext < th_E) = 0;
E_im_ext(E_im_ext >= th_E) = 1;
%     E_imOrig_distTrafo_ext = -bwdist(E_im_ext);
%     E_imOrig_distTrafo_ext = E_imOrig_distTrafo_ext + max(abs(E_imOrig_distTrafo_ext(:)));

dist_trafo_scale = 4; %5
E_imOrig_distTrafo_ext = exp(-bwdist(E_im_ext) / dist_trafo_scale);

%weight distance transform in the inner area

%----------------%
% Average images %
%----------------%

%superimpose images
imp_final1 = zeros(max_frame_h, max_frame_w, 3);    
imp_final3 = zeros(max_frame_h + border_ext_h, max_frame_w + border_ext_w, 3);
num_parts_h = 2;
num_parts_w = 2;
C_tot_parts = zeros(size(E_imOrig_distTrafo_ext));
C_tot = 0;

%init part containers
parts_2_average_images = cell(num_parts_h, num_parts_w);
parts_2_average_costs = cell(num_parts_h, num_parts_w);
parts_2_average_locations = cell(num_parts_h, num_parts_w);
parts_2_average_perPixelCosts = cell(num_parts_h, num_parts_w);

for l = 1:num_parts_w
    for k = 1:num_parts_h
        parts_2_average_images{k,l} = cell(length(frames2average), 1);
        parts_2_average_perPixelCosts{k,l} = cell(length(frames2average), 1);
        parts_2_average_costs{k,l} = zeros(length(frames2average), 1);
        parts_2_average_locations{k,l} = zeros(length(frames2average), 4);
    end
end

for j = 1:length(frames2average)

    %zero padding
    im = frames_tmp{j};
    [h, w, d] = size(im);  
    imp = zeros(max_frame_h, max_frame_w, 3);
    imp(mid_frame_h - floor(h/2):mid_frame_h - floor(h/2) + h - 1,...
        mid_frame_w - floor(w/2):mid_frame_w - floor(w/2) + w - 1, :) = im;  
    imp = uint8(imp);

%         subplot(size(seqs2average, 1) + 2, 10, (j-1) * 10 + max(1, mod(i, 11)))
%         imshow(imp);

%         %get edge image - Canny
%         E_imp = double(edge(rgb2gray(imp), 'canny', [lowthr, highthr]));
%         se = strel('disk', 1);
%         E_imp = double(imdilate(E_imp, se));

%       get edge image - Other
    [E_imp,~,~,~]=edgesDetect(imp, model_edge);
    E_imp(E_imp>highthr) = highthr;
    E_imp(E_imp<lowthr) = lowthr;
    E_imp = 1/highthr * E_imp;
    E_imp(E_imp < th_E) = 0;

    %Thinnening
    radius = 10;
    thr = 0.05;  
    [subs1,vals1] = nonMaxSupr(double(E_imp), radius);
    bw1nms = zeros(size(E_imp));
    bw1nms(sub2ind(size(bw1nms),subs1(:,1),subs1(:,2))) =...
        E_imp(sub2ind(size(bw1nms),subs1(:,1),subs1(:,2)));
    E_imp = double(bw1nms);    

    %remove edges due to zero padding
    E_imp(1:mid_frame_h - floor(h/2), :) = 0;
    E_imp(mid_frame_h - floor(h/2) + h - 2:end, :) = 0;
    E_imp(:, 1:mid_frame_w - floor(w/2)+1) = 0;
    E_imp(:, mid_frame_w - floor(w/2) + w - 2:end) = 0;

    %binarize
    E_imp(E_imp < th_E) = 0;
    E_imp(E_imp >= th_E) = 1;

    %compute part sizes
    part_size_h = floor(max_frame_h / num_parts_h);
    part_size_w = floor(max_frame_w / num_parts_w);

    for l = 1:num_parts_w
        for k = 1:num_parts_h

            if k < num_parts_h && l < num_parts_w
                part_start_h = (k-1) * part_size_h + 1;
                part_end_h = k * part_size_h;

                part_start_w = (l-1) * part_size_w + 1;
                part_end_w = l * part_size_w;   

            elseif k == num_parts_h && l < num_parts_w
                part_start_h = (k-1) * part_size_h + 1;
                part_end_h = max_frame_h;

                part_start_w = (l-1) * part_size_w + 1;
                part_end_w = l * part_size_w;   

            elseif k < num_parts_h && l == num_parts_w
                part_start_h = (k-1) * part_size_h + 1;
                part_end_h = k * part_size_h;

                part_start_w = (l-1) * part_size_w + 1;
                part_end_w = max_frame_w;

            else
                part_start_h = (k-1) * part_size_h + 1;
                part_end_h = max_frame_h;

                part_start_w = (l-1) * part_size_w + 1;
                part_end_w = max_frame_w;
            end

            E_imp_part = E_imp(part_start_h : part_end_h, ...
                part_start_w : part_end_w);

            E_imOrig_distTrafo_part =...
                E_imOrig_distTrafo_ext(part_start_h : part_end_h + border_ext_h - 1,...
                part_start_w : part_end_w + border_ext_w - 1);                

            %find best matching position
            C = conv2(double(E_imOrig_distTrafo_part),...
                double(fliplr(flipud(E_imp_part))), 'valid');

            [C_max, idx_max] = max(C(:));
            [I,J] = ind2sub(size(C), idx_max);
            if C_max < 0
                C_max = 0;
            end    
            C_max = C_max^2;

            %catch NaN-values
            if isnan(C_max)
                C_max = 0;  
            end

%                 figure;
%                 imshow(uint8(E_im_ext*255))
%                 hold on
%                 
%                 rectangle('Position',[part_start_w + border_ext_w/2 - 1, ...
%                 part_start_h + border_ext_h/2 - 1, ...
%                 part_end_w - part_start_w + 1, ...
%                 part_end_h - part_start_h + 1], ...
%                 'EdgeColor', 'r', 'LineWidth', 2);
%             
%                 rectangle('Position',[part_start_w, ...
%                 part_start_h, ...
%                 part_end_w - part_start_w + border_ext_w - 1, ...
%                 part_end_h - part_start_h + border_ext_h - 1], ...
%                 'EdgeColor', 'g', 'LineWidth', 2);
%             
%                 rectangle('Position',[part_start_w + J - 1, ...
%                 part_start_h + I - 1, ...
%                 part_end_w - part_start_w + 1, ...
%                 part_end_h - part_start_h + 1], ...
%                 'EdgeColor', 'y', 'LineWidth', 2);

            %update weights
            C_tot_parts(part_start_h + I - 1 : part_end_h + I - 1,...
                part_start_w + J - 1: part_end_w + J - 1) =...
                C_tot_parts(part_start_h + I - 1: part_end_h + I - 1,...
                part_start_w + J - 1 : part_end_w + J - 1) +...
                repmat(C_max, size(E_imp_part, 1), size(E_imp_part, 2));

            imp_final3(part_start_h + I - 1 : part_end_h + I - 1,...
                part_start_w + J - 1: part_end_w + J - 1, :)  =...
                double(imp_final3(part_start_h + I - 1: part_end_h + I - 1,...
                part_start_w + J - 1 : part_end_w + J - 1, :)) +...
                C_max * double(imp(part_start_h : part_end_h,...
                part_start_w : part_end_w, :));


            %save part data
            part_imgs = parts_2_average_images{k,l};
            part_imgs{j} = C_max * double(imp(part_start_h : part_end_h,...
                part_start_w : part_end_w, :));
            parts_2_average_images{k,l} = part_imgs;

            parts_costs = parts_2_average_costs{k,l};
            parts_costs(j) = C_max;
            parts_2_average_costs{k,l} = parts_costs;

            parts_locations = parts_2_average_locations{k,l};
            parts_locations(j,:) = [part_start_h + I - 1,...
                part_start_w + J - 1,...
                part_end_h + I - 1,...
                part_end_w + J - 1];
            parts_2_average_locations{k,l} = parts_locations;

            perPixelCosts = parts_2_average_perPixelCosts{k,l};
            perPixelCosts_tmp =...
                double(E_imOrig_distTrafo_ext(part_start_h + I - 1 : part_end_h + I - 1,...
                part_start_w + J - 1 : part_end_w + J - 1)) .* double(E_imp(part_start_h : part_end_h,...
                part_start_w : part_end_w));

%                 figure;
%                 imagesc(perPixelCosts)

            %# Create the gaussian filter with hsize = [5 5] and sigma = 2
            perPixelCosts_tmp = perPixelCosts_tmp + 0.8;  

%                 se = strel('disk', 3);
%                 perPixelCosts_tmp = imdilate(perPixelCosts_tmp, se);

            G = fspecial('gaussian',[50 50],2);
            perPixelCosts_tmp = imfilter(perPixelCosts_tmp,G,'same');
            perPixelCosts_tmp = perPixelCosts_tmp ./ max(perPixelCosts_tmp(:));
%                 figure; imagesc(perPixelCosts_tmp)

            perPixelCosts{j} = perPixelCosts_tmp;
            parts_2_average_perPixelCosts{k,l} = perPixelCosts;
        end
    end

    C = conv2(double(E_imOrig_distTrafo), double(fliplr(flipud(E_imp))), 'valid');
    C_tot = C_tot + C;

    %weighted
    imp_final1 = double(imp_final1) + C * double(imp);
end

%combine parts
imp_final4 = zeros(max_frame_h + border_ext_h, max_frame_w + border_ext_w, 3);
imp_final5 = zeros(max_frame_h + border_ext_h, max_frame_w + border_ext_w, 3);
C_tot_parts2 = zeros(max_frame_h + border_ext_h, max_frame_w + border_ext_w, 1);
C_tot_parts3 = zeros(max_frame_h + border_ext_h, max_frame_w + border_ext_w, 1);
num_parts_del = 3; % remove worst 3 parts per quadrant
for l = 1:num_parts_w
    for k = 1:num_parts_h
        %find worst k parts
        parts_costs = parts_2_average_costs{k,l};
        [~, idx_sort] = sort(parts_costs, 'ascend');

        parts_locations = parts_2_average_locations{k,l};
        parts_locations(idx_sort(1:num_parts_del), :) = [];

        part_imgs = parts_2_average_images{k,l};
        part_imgs(idx_sort(1:num_parts_del)) = [];

        perPixelCosts = parts_2_average_perPixelCosts{k,l};
        perPixelCosts(1:num_parts_del) = [];

        parts_costs(idx_sort(1:num_parts_del)) = [];

        %average over best parts
        for m = 1:numel(part_imgs)
            imp_final4(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4), :)  =...
                double(imp_final4(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4), :)) +...
                double(part_imgs{m});

            C_tot_parts2(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4)) =...
                double(C_tot_parts2(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4))) +...
                repmat(parts_costs(m), size(part_imgs{m}, 1), size(part_imgs{m}, 2));

            perPixelCosts_tmp = perPixelCosts{m};
            C_tot_parts3(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4)) =...
                double(C_tot_parts3(parts_locations(m,1) : parts_locations(m,3),...
                parts_locations(m,2) : parts_locations(m,4))) +...
                repmat(parts_costs(m), size(part_imgs{m}, 1), size(part_imgs{m}, 2))...
                .* perPixelCosts_tmp;


%                 %downweight image at the borders
%                 offset = 3;
%                 border_strip = ceil(size(perPixelCosts_tmp) / 5) + offset;
%                 mask_weight = zeros(size(perPixelCosts_tmp, 1) + 2 * offset,...
%                     size(perPixelCosts_tmp, 2) + 2 * offset);
%                 mask_weight(border_strip(1)+1:end-border_strip(1),...
%                     border_strip(2)+1:end-border_strip(2)) = 1;
%                 mask_weight_distTrans = -bwdist(mask_weight);
%                 mask_weight_distTrans = mask_weight_distTrans + ...
%                     max(abs(mask_weight_distTrans(:)));
%                 mask_weight_distTrans = mask_weight_distTrans / ...
%                     max(mask_weight_distTrans(:));
%                 
%                 mask_weight_distTrans = mask_weight_distTrans(...
%                     offset+1:end-offset, offset+1:end-offset);
%                 
%                 C_tot_parts3(parts_locations(m,1) : parts_locations(m,3),...
%                     parts_locations(m,2) : parts_locations(m,4)) =...
%                     double(C_tot_parts3(parts_locations(m,1) : parts_locations(m,3),...
%                     parts_locations(m,2) : parts_locations(m,4))) +...
%                     repmat(parts_costs(m), size(part_imgs{m}, 1), size(part_imgs{m}, 2))...
%                     .* mask_weight_distTrans;
        end
    end
end

%normalize averages

%weighted parts - perPixel
imp_final5 = imp_final4;
imp_final5(:,:,1) = imp_final5(:,:,1) ./ C_tot_parts3;
imp_final5(:,:,2) = imp_final5(:,:,2) ./ C_tot_parts3;
imp_final5(:,:,3) = imp_final5(:,:,3) ./ C_tot_parts3;
imp_final5 = uint8(imp_final5);

%blur weighted parts  
G = fspecial('gaussian',[3 3],1.5);
imp_final5 = imfilter(imp_final5,G,'same');
imp_final5 = uint8(imp_final5);

%weighted parts
imp_final4(:,:,1) = imp_final4(:,:,1) ./ C_tot_parts2;
imp_final4(:,:,2) = imp_final4(:,:,2) ./ C_tot_parts2;
imp_final4(:,:,3) = imp_final4(:,:,3) ./ C_tot_parts2;
imp_final4 = uint8(imp_final4);

imp_final4 = imfilter(imp_final4,G,'same');
imp_final4 = uint8(imp_final4);

%     %blur weighted parts
%     imp_final5 = imp_final4;    
%     G = fspecial('gaussian',[3 3],1.5);
%     imp_final5 = imfilter(imp_final5,G,'same');
%     imp_final5 = uint8(imp_final5);

%weighted
imp_final1 = uint8(imp_final1 / C_tot);

%weighted parts
imp_final3(:,:,1) = imp_final3(:,:,1) ./ C_tot_parts;
imp_final3(:,:,2) = imp_final3(:,:,2) ./ C_tot_parts;
imp_final3(:,:,3) = imp_final3(:,:,3) ./ C_tot_parts;
imp_final3 = uint8(imp_final3);

imp_final3 = imfilter(imp_final3,G,'same');
imp_final3 = uint8(imp_final3);

cd(main_dir);

%     subplot(size(seqs2average, 1) + 2, 10, size(seqs2average, 1) * 10 + max(1, mod(i, 11)));
%     imshow(im_orig);
%     
%     subplot(size(seqs2average, 1) + 2, 10, (size(seqs2average, 1)+1) * 10 + max(1, mod(i, 11)));
%     imshow(imp_final);
%     title('Average', 'FontSize', 6)

% Plotting results
figure(1111);
clf;

hFig = figure(1111);
clf;
set(hFig, 'Position', [1000 200 700 500])
subplot(1, 4, 1);
imshow(im_orig);
title(sprintf('Original - Frame %d', i), 'FontSize', 10)

subplot(1, 4, 2);
imshow(imp_final3);
title('Average - weighted Parts', 'FontSize', 10)

subplot(1, 4, 3);
imshow(imp_final4);
title('Average - weighted Parts (sel)', 'FontSize', 10)

subplot(1, 4, 4);
imshow(imp_final1);
title('weighted', 'FontSize', 10)

% subplot(1, 5, 5);
% imshow(imp_final5);
% title('Average - weighted Parts (sel + PPW)', 'FontSize', 6)

res_1 = imp_final3;
res_2 = imp_final4;
end

