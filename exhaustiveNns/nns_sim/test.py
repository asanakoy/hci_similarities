#!/usr/bin/python

import time
import h5py
import heapq
import scipy.signal
import os.path
import math
import sys
from multiprocessing import Pool

from datetime import datetime
from pprint import pprint
from hogsimilarity import get_hog_similarity
import datasetstructure
from sharedcounter import SharedCounter

__author__ = 'asanakoy'


class Shared:
    hog = None
    category_lookup_table = None
    ds = None
    counter = SharedCounter(0)


# noinspection PyPep8Naming
def main():
    # print "Reading hog..."
    DATASET_PATH = '/export/home/asanakoy/workspace/OlympicSports'
    Shared.ds = datasetstructure.DatasetStructure(DATASET_PATH)
    # WHITEHOG_PATH = '/export/home/asanakoy/workspace/' \
    #                 'OlympicSports/whitehog/long_jump/-wmGlrcdXgU_01290_01392.mat'

    print "Reading data..."
    startTime = time.time()

    # hogFile = h5py.File(Shared.ds.get_whitehog_filepath(), 'r')
    hogFile = h5py.File('/export/home/asanakoy/workspace/hog.mat', 'r')
    Shared.hog = [hogFile[idx[0]][:] for idx in hogFile['/hog']]
    print "Number of vectors: ", len(Shared.hog)
    print "Done."

    #############################################################

    print "Reading categotyLookupTable..."
    dataInfoFile = h5py.File(Shared.ds.get_datainfo_filepath(), 'r')
    Shared.category_lookup_table = dataInfoFile['categoryLookupTable'][:]
    print "categotyLookupTable size: ", Shared.category_lookup_table.size
    print("Done.\nReading and preparing data: %s seconds ---" % (time.time() - startTime))

    #############################################################

    for i in range(20):
        startTime = time.time()
        get_hog_similarity(Shared.hog[0], Shared.hog[1], 1)
        print("Elapsed time is %s seconds ---" % (time.time() - startTime))


    N = len(Shared.hog)
    NUM_BATCHES = 100
    BATCH_SIZE = int(math.floor(N / NUM_BATCHES))
    print('Batches:%d, BATCH_SIZE:%d\n' % (NUM_BATCHES, BATCH_SIZE))

    nWorkers = 1
    step = BATCH_SIZE
    print('running %d workers, chunk size: %d\n' % (nWorkers, step))

    #############################################################
    pool = Pool(processes=nWorkers)
    #args = [(i, i * step, min((i + 1) * step, len(Shared.hog))) for i in range(NUM_BATCHES)]
    args = [(0, 0, 1)]
    procChunk(args[0])
    # print "Mapping proc Pool"
    # pool.map(procChunk, args)
    # print "Pool mapped"
    # pool.close()
    # print "Pool closed"
    # pool.join()
    # print "Pool joined"


def procChunk((thread_id, begin, end)):

    LINE_BUFFERING = 1
    logFileName = "proc_%02d_log.txt" % thread_id
    f = open(logFileName, 'w', LINE_BUFFERING)

    timestamp = datetime.now().strftime('%d.%m %H:%M:%S')
    f.write("%s. started chunk %d\n" % (timestamp, thread_id))
    print "\n%s. started chunk %d" % (timestamp, thread_id)
    # print "Len hog: ", len(hog)
    chunkSize = end - begin
    nns = [[] for _ in range(chunkSize)]
    distances = [[] for _ in range(chunkSize)]
    isFlipped = [[] for _ in range(chunkSize)]

    HOG_PADDING_SIZE = 1
    NUMBER_OF_NNS = 10

    print "Range: ", begin, " : ", end
    for searchedIndex in range(begin, end):
        currentCategory = Shared.category_lookup_table[searchedIndex]

        h = Shared.hog[searchedIndex]
        h_reversed = h[::-1, ::-1, ::-1]
        h_flipped_reversed = h[::-1, :, ::-1]

        startTimeTic = time.time()
        for i in range(0, len(Shared.hog)):
            if i == searchedIndex or Shared.category_lookup_table[i] == currentCategory:
                continue
            if i % 100 == 0:
                sys.stdout.write("\r%d" % i)
                sys.stdout.flush()

            (similarity, is_image_flipped) = \
                get_hog_similarity(h, Shared.hog[i], HOG_PADDING_SIZE, h_reversed, h_flipped_reversed)

            heapq.heappush(nns[searchedIndex - begin], (similarity, i + 1, is_image_flipped))  # i + 1 to make indices 1-based
                                                                                # (for matlab)
            if len(nns[searchedIndex - begin]) > NUMBER_OF_NNS:
                heapq.heappop(nns[searchedIndex - begin])

        print("Sim calculation for every pair: %s seconds ---" % (time.time() - startTimeTic))
        tmp = [heapq.heappop(nns[searchedIndex - begin]) for _ in range(len(nns[searchedIndex - begin]))]
        tmp.reverse()  # reverse because we have min heap
        nns[searchedIndex - begin] = [tmp[k][1] for k in range(len(tmp))]  # neighbour indices
        distances[searchedIndex - begin] = [tmp[k][0] for k in range(len(tmp))]  # distances to the neighbours
        isFlipped[searchedIndex - begin] = [tmp[k][2] for k in range(len(tmp))]  # was neighbour image flipped?
        # print "Size of nns: ", len(nns[searchedIndex])

        Shared.counter.increment()
        cnt = Shared.counter.value()
        if cnt % 1 == 0:
            timestamp = datetime.now().strftime('%d.%m %H:%M:%S')
            print "\n%s. %d: Frames processed: %d" % (timestamp, thread_id, cnt)

        if (searchedIndex - begin + 1) % 1 == 0:
            timestamp = datetime.now().strftime('%d.%m %H:%M:%S')
            f.write("%s. %d: Frames processed: %d / %d\n" %
                    (timestamp, thread_id, searchedIndex - begin + 1, end - begin))

        if (searchedIndex - begin + 1) % 1000 == 0:
            saveSnapshot(thread_id,
                         os.path.join(Shared.ds.get_conv1_nns_path(),
                                      "snapshot_%d_nns_all_%06d_%06d.mat" %
                                      (searchedIndex - begin + 1, begin, end)),
                         nns, distances, isFlipped)
            f.write("%d: saved snapshot" % thread_id)

    f.close()
    saveSnapshot(thread_id,
                 os.path.join(Shared.ds.get_conv1_nns_path(), "nns_all_%06d_%06d.mat" % (begin, end)),
                 nns, distances, isFlipped)


def saveSnapshot(threadId, filename, nns, distances, isFlipped):
        print "\n%d: Saving data to %s ..." % (threadId, filename)
        # scipy.io.savemat(filename, mdict={'nns': nns, 'distances': distances,
        #                               'isFlipped': isFlipped})
        print "\n%d: Saved!" % threadId


if __name__ == "__main__":
    startTimeTic = time.time()
    main()
    print("NNs searching was done: %s seconds ---" % (time.time() - startTimeTic))
