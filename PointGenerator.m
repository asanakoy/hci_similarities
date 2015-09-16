classdef PointGenerator < handle
    %POINTGENERATOR utility class to generate random points from range.
    %   Probability of the point to be picked decreases with the number of
    %   times it was previously picked, compared to the total number of
    %   points picked before.
    
    properties (Constant)
        INITIAL_FREQUENCY = 0.001;
    end
    
    properties
        frequencyTable_
    end
    
    methods
        function obj = PointGenerator(totalNumberOfPoints)
            obj.frequencyTable_ = repmat(PointGenerator.INITIAL_FREQUENCY, totalNumberOfPoints, 1);
        end
      
        function updateFrequencyTable(obj, cliques)
            pickedPointsTable = zeros(size(obj.frequencyTable_));
            for i=1:length(cliques)
                pickedPointsTable(cliques{i}) = 1;
            end
            obj.frequencyTable_ = obj.frequencyTable_ + pickedPointsTable;
        end
        
        function point = drawPointFromSet(obj, pointSet)
            chancesTable = obj.frequencyTable_(pointSet).^(-1);
            point = randsample(pointSet, 1, true, chancesTable);
        end
        
    end
    
end

