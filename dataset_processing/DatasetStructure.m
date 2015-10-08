classdef DatasetStructure
    properties (Constant)   
        DATASET_PATH     = '/export/home/asanakoy/workspace/OlympicSports/';
        CLIPS_DIR        = 'clips';
        BBOXES_DIR       = 'boxes';
        FRAMES_DIR       = 'frames';
        CROPS_DIR        = 'crops';
        WHITEHOG_DIR     = 'whitehog';
        PAIRWISE_SIM_DIR = 'pairwise_sim';
        SIM_DIR          = 'similarities';
        DATA_DIR         = 'data';
        WHITEHOG_TILED_DIR = 'whitehog_tiled';
    end
    
    methods(Static)
    
        function path = getDataInfoPath(dataset_path)
            if nargin < 1 || isempty(dataset_path)
                dataset_path = DatasetStructure.DATASET_PATH;
            end
            path = fullfile(dataset_path, DatasetStructure.DATA_DIR, 'dataInfo.mat');
        end
        
        function path = getDataDirPath(dataset_path)
            if nargin < 1 || isempty(dataset_path)
                dataset_path = DatasetStructure.DATASET_PATH;
            end
            path = fullfile(dataset_path, DatasetStructure.DATA_DIR);
        end
        
        function path = getWhitehogDirPath(dataset_path)
            if nargin < 1 || isempty(dataset_path)
                dataset_path = DatasetStructure.DATASET_PATH;
            end
            path = fullfile(dataset_path, DatasetStructure.WHITEHOG_DIR);
        end
        
        function path = getWhitehogTiledDirPath(dataset_path)
            if nargin < 1 || isempty(dataset_path)
                dataset_path = DatasetStructure.DATASET_PATH;
            end
            path = fullfile(dataset_path, DatasetStructure.WHITEHOG_TILED_DIR);
        end
        
    end
    
end