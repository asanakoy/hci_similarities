

%%% Read all sequences

cname = dir('/export/scratch/bantic/Videos/OlympicSports/whitehog/');
idx = arrayfun(@(x) x.name(1)~='.',  cname);
cname = {cname(idx).name};


for k = 1:numel(cname)
    
    class = cname{k};
    
    fname = dir(['/export/scratch/bantic/Videos/OlympicSports/whitehog/' class '/*.mat']);
    
    mkdir(['/export/scratch/bantic/Videos/OlympicSports/pairwise_sim/' class])
    
    for i = 1:numel(fname)
        for j = i:numel(fname)
            
            disp(sprintf('%s: (%d,%d)', class, i, j))
    
            load(['/export/scratch/bantic/Videos/OlympicSports/whitehog/' class '/' fname(i).name]);
            hog1 = hog;
            
            load(['/export/scratch/bantic/Videos/OlympicSports/whitehog/' class '/' fname(j).name]);
            hog2 = hog;
            
            tic; 
            [val, I, J] = hog_similarity(hog1, hog2, 2); 
            toc
            
            save(sprintf('/export/scratch/bantic/Videos/OlympicSports/pairwise_sim/%s/%s__%s.mat', ...
                class, fname(i).name(1:end-4), fname(j).name(1:end-4)), 'val', 'I', 'J');
    
        end
    end
end


