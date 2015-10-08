function [] = pairwise_similarities(white_hog_path, o_pairwise_sim_path)
% Build pairwise similarities for set of sequences inside each category.

if nargin < 2 || isempty(white_hog_path) || isempty(o_pairwise_sim_path)
    white_hog_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/whitehog/';
    o_pairwise_sim_path = '/net/hciserver03/storage/asanakoy/workspace/HMDB51/pairwise_sim';
end

%%% Read all sequences

cname = dir(white_hog_path);
idx = arrayfun(@(x) x.name(1)~='.',  cname);
cname = {cname(idx).name};


for k = 34:numel(cname)
    
    class = cname{k};
    
    fname = dir(fullfile(white_hog_path, class, '*.mat'));
    
    mkdir(fullfile(o_pairwise_sim_path, class))
    
    for i = 1:numel(fname)
        for j = i:numel(fname)
            
            fprintf('%s: (%d,%d)\n', class, i, j);
            
            filename = sprintf('%s__%s.mat', fname(i).name(1:end-4), fname(j).name(1:end-4));
            filepath = fullfile(o_pairwise_sim_path, class, filename);
            if (~exist(filepath, 'file'))
            
                load(fullfile(white_hog_path, class, fname(i).name));
                hog1 = hog;

                load(fullfile(white_hog_path, class, fname(j).name));
                hog2 = hog;

                tic; 
                [val, I, J] = hog_similarity(hog1, hog2, 2);  %#ok<ASGLU>
                toc

                save(filepath, 'val', 'I', 'J');
            end
    
        end
    end
end

end

