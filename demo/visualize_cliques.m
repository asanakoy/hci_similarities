function [] = visualize_cliques( category,cliques,flips,k,j )
%VISUALIZE_CLIQUES Summary of this function goes here
%   Detailed explanation goes here

load(['/net/hciserver03/storage/mbautist/Desktop/projects/cnn_similarities/datasets/ucf_sports/sim_predre_hog_for/simMatrix_',category,'.mat']);
clique = cliques{k}{j};
flip = flips{k}{j};
pathtodata = ['/net/hciserver03/storage/mbautist/Desktop/projects/cnn_similarities/datasets/OlympicSports/crops/',category,'/'];

for i = 1:length(clique)
    
    
    name_frame = image_names(clique(i),3:end);
    fparts = strsplit(name_frame,'/');
    name_frame = [fparts{1},'/',sprintf('I%05d.png',str2num(fparts{2}(2:6))-1)];
    
    im=imresize(imread(fullfile(pathtodata,name_frame)),[200,200]);
    if flip(i) == 1
        stack(:,:,:,i)=im(:,end:-1:1,:);
    else
        stack(:,:,:,i)=im;
        
    end
    
    
end
h = implay(stack);
set(h.Parent, 'Name', ['Batch',num2str(k),', Clique ',num2str(j)]);

end


