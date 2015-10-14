function [ ] = showNeighbours( dataset_path, nns, distances, isFlipped, sequnceFilesPathes, sequencesLookupTable )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

assert(length(nns) == length(distances));

for i = 1:length(nns)
    imageLabel = sprintf('%d. id: %d;\ndist: %f', i, nns(i), distances(i));
    figure;
    showImage(nns(i), dataset_path, sequnceFilesPathes, sequencesLookupTable, imageLabel, isFlipped(i));
%     fprintf('Id: %d, isFlipped: %d\n', nns(i), isFlipped(i));
    pause;
%     str = input('input:','s');
%     if strcmp(str, 's')
%         figure;
%     end
end

% stack = zeros(200, 200, 3, length(nns));

% for i = 1:length(nns)
%     
%     im=imresize(imread(getImagePath(nns(i), sequnceFilPathes, sequencesLookupTable)),[200,200]);
%     stack(:,:,:,i)=im;
%         
% end
% h = implay(stack);
% set(h.Parent, 'Name', [length(nns), 'Nearest neigbours']);

end

