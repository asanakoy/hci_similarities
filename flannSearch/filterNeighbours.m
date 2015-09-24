function [ sameCategoryNeighbours, sameCategoryDistances, otherNeighbours, otherDistances ] =...
    filterNeighbours( searchedFrameId, neighboursIds, distances, categoryLookuptable )

%FILETRNEIGHBOURS Separate neighbours in the same category from neighbours in
%other categories

searchedCategory = categoryLookuptable(searchedFrameId);
sameCatIndices = []; 

for i=1:length(neighboursIds)
%     assert(neighboursIds(i) ~= searchedFrameId);

    if ( categoryLookuptable(neighboursIds(i)) == searchedCategory )
        sameCatIndices = [sameCatIndices i];
    end

end


sameCategoryNeighbours = neighboursIds(sameCatIndices);
sameCategoryDistances = distances(sameCatIndices);

otherCatIndices = setdiff(1:length(neighboursIds), sameCatIndices);
otherNeighbours = neighboursIds(otherCatIndices);
otherDistances = distances(otherCatIndices);

end



