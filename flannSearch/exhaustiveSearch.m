NUMBER_OF_NNS = 20;

searchedIndex = 1;
tic;
fprintf('Iteration:         ');
mindist = flintmax;
nns = [];


for i = 2:size(hogVectors, 2)
    if (i == searchedIndex)
        continue;
    end
%     if (mod(i, 100) == 0)
%         fprintf('\b\b\b\b\b\b\b%7d', i);
%     end
    delta = hogVectors(:, searchedIndex) - hogVectors(:,i);
    dist = sum(delta .* delta); 

    if (length(nns) < NUMBER_OF_NNS)

    end
    
    if (dist < mindist)
        idx = i;
        mindist = dist;
    end
end
fprintf('\n');
toc

function addToNns