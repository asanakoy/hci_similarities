function [] = runProcessing( dataset_path )
%Run procedures to compute different stuff for dataset

computeHog(fullfile(dataset_path, DatasetStructure.CROPS_DIR),...
           fullfile(dataset_path, DatasetStructure.HOG_DIR));
       
hog_whitening(fullfile(dataset_path, DatasetStructure.HOG_DIR),...
              fullfile(dataset_path, DatasetStructure.WHITEHOG_DIR));

buildAllSimMatrices(dataset_path);

end

