import os.path

__author__ = 'asanakoy'

class DatasetStructure:
    CLIPS_DIR        = 'clips'
    BBOXES_DIR       = 'boxes'
    FRAMES_DIR       = 'frames'
    CROPS_DIR        = 'crops'
    WHITEHOG_DIR     = 'whitehog'
    PAIRWISE_SIM_DIR = 'pairwise_sim'
    SIM_DIR          = 'similarities'
    DATA_DIR         = 'data'
    WHITEHOG_TILED_DIR = 'whitehog_tiled'
    CONV1_NNS_DIR      = 'conv1_nns'

    def __init__(self, dataset_path):
        self.dataset_path = dataset_path

    def get_whitehog_filepath(self):
        return os.path.join(self.dataset_path, DatasetStructure.DATA_DIR, 'whitehog_all.mat')

    def get_datainfo_filepath(self):
        return os.path.join(self.dataset_path, DatasetStructure.DATA_DIR, 'dataInfo.mat')

    def get_conv1_nns_path(self):
        return os.path.join(self.dataset_path, DatasetStructure.DATA_DIR, DatasetStructure.CONV1_NNS_DIR)
