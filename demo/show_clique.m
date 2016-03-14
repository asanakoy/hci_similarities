function [] = show_clique(data_info, cliques, flips, offset, k, j )
%SHOW_CLIQUE Summary of this function goes here
%   Detailed explanation goes here


dataset_path = '~/workspace/OlympicSports';
clique = cliques{k}{j};
flip = flips{k}{j};

for i = 1:length(clique)
    frame_id = clique(i) + offset;
    img_path = getImagePath( frame_id, dataset_path, data_info.sequenceFilesPathes, data_info.sequenceLookupTable);
    fprintf('%d: %s\n', i, img_path);
    im=imresize(imread(img_path),[227,227]);
    if flip(i) == 1
        stack(:,:,:,i)=im(:,end:-1:1,:);
    else
        stack(:,:,:,i)=im;
        
    end
    
    
end
h = implay(stack);
set(h.Parent, 'Name', ['Batch',num2str(k),', Clique ',num2str(j)]);

end

