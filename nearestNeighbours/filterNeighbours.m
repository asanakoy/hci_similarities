function [ sameCategoryNeighbours, sameCategoryDistances, otherNeighbours, otherDistances, otherIsFlipped ] =...
    filterNeighbours( searchedFrameId, neighboursIds, distances, isFlipped, categoryLookuptable )

%FILETRNEIGHBOURS Separate neighbours in the same category from neighbours in
%other categories

searchedCategory = categoryLookuptable(searchedFrameId);
sameCatIndices = uint32.empty(0,0); 

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
otherIsFlipped = isFlipped(otherCatIndices);

end



