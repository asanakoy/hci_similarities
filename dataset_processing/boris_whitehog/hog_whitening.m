hogFolder = 'HOG/Video1/hog/';
whitenedHogFolder = 'HOG/Video1/whitened_hog/';

dirnames = dir(hogFolder);
idx = arrayfun(@(x)x.name(1)=='.',dirnames);
dirnames(idx) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compute HOG mean
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('hog_mu','var')

    hog_mu = zeros(1,1,31,'single');
    hog_size = [];
    nsamples = 0;
    
    for i = 1:numel(dirnames)
        
        cname = dirnames(i).name;
        
        videonames = dir([hogFolder cname]);
        idx = arrayfun(@(x)x.name(1)=='.',videonames);
        videonames(idx) = [];
        
        for j = 1:numel(videonames)
            
            vname = videonames(j).name;            
            load([hogFolder cname '/' vname]);
            
            for k = 1:numel(hog)                
                
                H = hog(k).data;
                hog_mu = hog_mu + sum(sum(H,1),2);
                nsamples = nsamples + size(H,1) * size(H,2);
                
                hog_size(end+1,:) = size(H);
            end
        end
    end
    
    hog_mu = hog_mu / nsamples;
    hog_size = unique(hog_size, 'rows');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compute HOG covariance 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(hog_size,1)
    hogsum(i).data = zeros(prod(hog_size(i,:)),prod(hog_size(i,:)),'single');
    hogsum(i).nsamples = 0;
end


for i = 1:numel(dirnames)
    
    cname = dirnames(i).name;
    videonames = dir([hogFolder cname]);
    idx = arrayfun(@(x)x.name(1)=='.',videonames);
    videonames(idx) = [];
    
    for j = 1:numel(videonames)
        
        vname = videonames(j).name;        
        res = load([hogFolder cname '/' vname]);
        hog = res.hog;
            
        for k = 1:numel(hog)
            
            t0 = tic;
            
            % subtract the mean
            H = bsxfun(@minus,hog(k).data,hog_mu);
            
            % reshape hog matrix
            hogvec = reshape(permute(H, [3,1,2]), [], 1);
            
            % 
            idx = find(hog_size(:,1)==size(H,1) & hog_size(:,2)==size(H,2));
            
            % compute the sample covariance
            hogsum(idx).data = hogsum(idx).data + hogvec * hogvec';
            hogsum(idx).nsamples = hogsum(idx).nsamples + 1;
            
            t1 = toc(t0);
            
            disp(sprintf('(%d,%d,%d): %.2f seconds', i,j,k,t1));
        end
    end
end


displ = [];
for i = 1:size(hog_size,1) 
    [X,Y] = meshgrid(1:hog_size(i,2),1:hog_size(i,1));

    Xdiff = bsxfun(@minus, X(:), X(:)');
    Ydiff = bsxfun(@minus, Y(:), Y(:)');
    
    Idx = (Ydiff<0) | (Ydiff==0 & Xdiff<0);
    Xdiff(Idx) = -Xdiff(Idx);
    Ydiff(Idx) = -Ydiff(Idx);
    
    displ = cat(1, displ, [repmat(i,length(Ydiff(:)),1), ...
                Ydiff(:), Xdiff(:), Idx(:)]);    
end

[cdbook,~,IC] = unique(displ(:,2:3),'rows');

displ = cat(2,displ,IC);

C = cell(size(cdbook,1),1);
nsamples = zeros(size(cdbook,1),1);

for i = 1:size(hog_size,1)
    
    disp(i)

    M = hog_size(i,1); 
    N = hog_size(i,2);
    K = hog_size(i,3);
    
    H = mat2cell(hogsum(i).data, repmat(K,1,M*N), repmat(K,1,M*N));
    D = displ(displ(:,1)==i, :);
    
    for j = 1:size(cdbook,1)
        
        idx = find(D(:,4)==0 & D(:,5)==j);

        if isempty(C{j})
            C{j} = zeros(K,K,'single');
        end
        
        if isempty(idx)
            continue
        end
        
        C{j} = C{j} + sum(cat(3,H{idx}),3);
        nsamples(j) = nsamples(j) + hogsum(i).nsamples * length(idx);
    end
end


R = cell(size(hog_size,1),1);

for i = 1:size(hog_size,1)
    
    disp(i)
    
    M = hog_size(i,1); 
    N = hog_size(i,2);
    K = hog_size(i,3);
    
    D = displ(displ(:,1)==i, :);
    H = cell(length(D),1);
    
    for j = 1:size(cdbook,1)
        idx = find(D(:,4)==0 & D(:,5)==j);
        
        if isempty(idx)
            continue
        end
        
        H(idx) = C(j);
        
        idx = find(D(:,4)==1 & D(:,5)==j);
        
        if isempty(idx)
            continue
        end
        
        H(idx) = {(C{j})'};
        
    end

    H = cell2mat(reshape(H,M*N,M*N));
    H = H / max(nsamples) + .02 * eye(size(H));
    
    R{i} = chol(H);
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Decorrelate HOG features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
for i = 1:numel(dirnames)
    
    cname = dirnames(i).name;
    videonames = dir([hogFolder cname]);
    idx = arrayfun(@(x)x.name(1)=='.',videonames);
    videonames(idx) = [];
    
    for j = 1:numel(videonames)
        
        vname = videonames(j).name;
        load([hogFolder cname '/' vname]);
        
        mkdir([whitenedHogFolder cname])
        
        for k = 1:numel(hog)
            
            t0 = tic;
            
            H = hog(k).data;
            [M,N,K] = size(H);
            H0 = bsxfun(@minus, H, hog_mu);
            hog_vec = reshape(permute(H0, [3,1,2]), [], 1);
            
            idx = find(hog_size(:,1)==size(H,1) & hog_size(:,2)==size(H,2));
            hog_vec = (R{idx})' \ hog_vec;
            
            Hdec = permute(reshape(hog_vec, [K, M, N]), [2,3,1]);
            hog(k).data = Hdec;
            
            t1 = toc(t0);
            disp(sprintf('(%d,%d,%d): %.2f seconds', i,j,k,t1));
            
            
        end
        
        save([whitenedHogFolder cname '/' vname],'hog');
        
    end
end

