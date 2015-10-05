classdef FlannHandler < handle
    %FLANNHANDLER utility class to test Flan
    
    properties (Constant)
        
    end
    
    properties
        flannIndex_
        data_
        searchParameters_
    end
    
    methods
        function obj = FlannHandler()
        end
      
        function init(obj, datasetPath, indexPath, parametersPath)
            tic;
            fprintf('loading data into memory...\n');
            obj.data_ = load(datasetPath);
            
            fprintf('loading index into memory...\n');
            obj.flannIndex_ = flann_load_index(indexPath, obj.data_.hogVectors);
            
            fprintf('loading parameters into memory...\n');
            obj.searchParameters_ = load(parametersPath);
            fprintf('FlannHandler Initialization DONE.\n');
            toc
        end
        
        function [neighboursIndices, distanses] = getNns(obj, point, numberOfNns)
            
            fprintf('Searching NNs...\n');
            tic;
            [neighboursIndices, distanses] = flann_search(obj.flannIndex_, point, numberOfNns, obj.searchParameters_.parameters);
            fprintf('Searching DONE.\n');
            toc
            
        end
        
        function delete(obj)
           flann_free_index(obj.flannIndex_);
        end 
        
    end
    
end
