#!/usr/bin/python
import h5py
import heapq
import time
import numpy
import math
import scipy.io
from datetime import datetime
from multiprocessing import Pool, Array
import gc
import sys


__author__ = 'asanakoy'

class Shared:
  hogVectors = None
  hogVectorsFlipped = None
  categoryLookuptable = None

# noinspection PyPep8Naming
def main():

    print "Reading data..."
    startTime = time.time()

    # (hogVectors, shared_hogVectors_base) = readMatFileToSharedMemory('/net/hciserver03/storage/asanakoy/workspace/similarities/hog_tiled/hog_all.mat',
    #                           'hogVectors')
    # hogVectorsFlipped = readMatFileToSharedMemory('/net/hciserver03/storage/asanakoy/workspace/similarities/hog_tiled/hogFlipped_all.mat',
    #                            'hogVectorsFlipped')
    # filepath = '/net/hciserver03/storage/asanakoy/workspace/similarities/hog_tiled/hog_all.mat'
    dataset_path = '/export/home/asanakoy/workspace/OlympicSports/'
    filepath = dataset_path + 'whitehog_tiled/hog_all.mat'
    print "Reading  file ", filepath
    hogFile = h5py.File(filepath, 'r')
    Shared.hogVectors = hogFile['hogVectors'][:]
    print "Number of vectors: ", len(Shared.hogVectors)
    print "Done."
    # filepath = '/net/hciserver03/storage/asanakoy/workspace/similarities/hog_tiled/hogFlipped_all.mat'
    filepath = dataset_path + 'whitehog_tiled/hogFlipped_all.mat'
    print "Reading  file ", filepath
    hogFile = h5py.File(filepath, 'r')
    Shared.hogVectorsFlipped = hogFile['hogVectorsFlipped'][:]
    print "Number of flipped vectors: ", len(Shared.hogVectorsFlipped)
    print "Done."
    #############################################################

    print "Reading categotyLookupTable..."
    dataInfoFile = h5py.File(dataset_path + 'data/dataInfo.mat', 'r')
    Shared.categoryLookuptable = dataInfoFile['categoryLookupTable'][:]
    print "categotyLookupTable size: ", Shared.categoryLookuptable.size
    print("Done.\nReading and preparing data: %s seconds ---" % (time.time() - startTime))

    #############################################################
    nWorkers = 80
    step = int(math.ceil(1.0 * len(Shared.hogVectors) / nWorkers))
    print('running %d workers, chunk size: %d\n' % (nWorkers, step))

    #############################################################
    pool = Pool(processes=nWorkers)
    args = [(i, i * step, min((i + 1) * step, len(Shared.hogVectors))) for i in range(nWorkers)]

    print "Mapping proc Pool"
    pool.map(procChunk, args)
    print "Pool mapped"
    pool.close()
    print "Pool closed"
    pool.join()
    print "Pool joined"

    return

# noinspection PyPep8Naming
def procChunk((threadId, begin, end)):
    logFileName = "proc_%d_log.txt" % threadId
    f = open(logFileName, 'w')

    f.write("\nstarted worker %d" % threadId)
    print "\nstarted worker %d" % threadId
    # print "Len HogVectors: ", len(hogVectors)
    chunkSize = end - begin
    nns = [[] for _ in range(chunkSize)]
    distances = [[] for _ in range(chunkSize)]
    isFlipped = [[] for _ in range(chunkSize)]

    NUMBER_OF_NNS = 1000

    # print "Range: ", begin, " : ", end
    for searchedIndex in range(begin, end):

        currentCategory = Shared.categoryLookuptable[searchedIndex]

        for i in range(0, len(Shared.hogVectors)):
            if i == searchedIndex or Shared.categoryLookuptable[i] == currentCategory:
                continue

            isImageFlipped = 0
            dist = getDistanceSquared(Shared.hogVectors[searchedIndex], Shared.hogVectors[i])
            distWithFlipped = getDistanceSquared(Shared.hogVectors[searchedIndex], Shared.hogVectorsFlipped[i])
            if distWithFlipped < dist:
                isImageFlipped = 1
                dist = distWithFlipped

            heapq.heappush(nns[searchedIndex - begin], (-dist, i + 1, isImageFlipped))  # i + 1 to make indices 1-based
                                                                                # (for matlab)
            if len(nns[searchedIndex - begin]) > NUMBER_OF_NNS:
                heapq.heappop(nns[searchedIndex - begin])

        tmp = [heapq.heappop(nns[searchedIndex - begin]) for _ in range(len(nns[searchedIndex - begin]))]
        tmp.reverse()  # reverse because we have max heap
        nns[searchedIndex - begin] = [tmp[k][1] for k in range(len(tmp))]  # neighbour indices
        distances[searchedIndex - begin] = [-tmp[k][0] for k in range(len(tmp))]  # distances to the neighbours
        isFlipped[searchedIndex - begin] = [tmp[k][2] for k in range(len(tmp))]  # was neighbour image flipped?
        # print "Size of nns: ", len(nns[searchedIndex])

        if (searchedIndex - begin + 1) % 30 == 0:
            timestamp = datetime.now().strftime('%d.%m %H:%M:%S')
            f.write("\n%s. %d: Frames processed: %d / %d" % (timestamp, threadId, searchedIndex - begin + 1, end - begin))

        if (searchedIndex - begin + 1) % 900 == 0:
            saveSnapshot(threadId, "snapshot_%d_nns_all_%05d_%05d.mat" % (searchedIndex - begin + 1, begin, end),
                         nns, distances, isFlipped)
            f.write("%d: saved snapshot" % threadId)

    f.close()
    saveSnapshot(threadId, "nns_all_%05d_%05d.mat" % (begin, end), nns, distances, isFlipped)


def saveSnapshot(threadId, filename, nns, distances, isFlipped):
        print "\n%d: Saving data to %s ..." % (threadId, filename)
        scipy.io.savemat(filename, mdict={'nns': nns, 'distances': distances,
                                      'isFlipped': isFlipped})
        print "\n%d: Saved!" % threadId


def getDistanceSquared(a, b):
    delta = a - b
    return numpy.dot(delta.T, delta)


if __name__ == "__main__":
    startTime = time.time()
    main()
    print("NNs searching was done: %s seconds ---" % (time.time() - startTime))
