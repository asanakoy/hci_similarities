#!/usr/bin/python
import h5py
import heapq
import time
import numpy
import math
import scipy.io
from threading import Thread

__author__ = 'asanakoy'

def main():
    startTime = time.time()
    f = h5py.File('/net/hciserver03/storage/asanakoy/workspace/similarities/hogForFlann/hogForFlann_all.mat', 'r')
    hogVectors = f['hogVectors'][:]
    print "Number of vectors: ", len(hogVectors)

    catLookuptableFile = h5py.File('/net/hciserver03/storage/asanakoy/workspace/similarities/'
                                   'flannSearch/flannData/categoryLookupTable_all.mat', 'r')
    categoryLookuptable = catLookuptableFile['categoryLookupTable'][0][:]
    print "categotyLookupTable size: ", categoryLookuptable.size
    print("Reading: %s seconds ---" % (time.time() - startTime))

    # step = 10000
    # pool = Pool()
    # nThreads = int(math.ceil((1.0*len(hogVectors)) / step))

    nns = [[] for _ in range(len(hogVectors))]
    distances = [[] for _ in range(len(hogVectors))]

    nThreads = 12
    step = int(math.ceil(1.0*len(hogVectors) / nThreads))
    print('running %d threads, chunk size: %d\n' % (nThreads, step))

    threads = [Thread(target=procChunk,
                      args=(i, i * step, min((i+1) * step, len(hogVectors)), nns, distances, hogVectors, categoryLookuptable))
               for i in range(nThreads)]

    [t.start() for t in threads]
    [t.join() for t in threads]  # wait for threads to finish

    filename = "nns_100files.mat"
    print "Master: Saving all to %s ..." % filename
    scipy.io.savemat(filename, mdict={'nns': nns, 'distances': distances})
    print "Master: Saved!"

    return


def procChunk(threadId, begin, end, nns, distances, hogVectors, categoryLookuptable):
    print "\nstarted thread ", threadId
    NUMBER_OF_NNS = 1000

    for searchedIndex in range(begin, end):
        currentCategory = categoryLookuptable[searchedIndex]

        for i in range(0, len(hogVectors)):
            if i == searchedIndex or categoryLookuptable[i] == currentCategory:
                continue

            delta = hogVectors[searchedIndex] - hogVectors[i]
            distSquared = numpy.dot(delta.T, delta)

            heapq.heappush(nns[searchedIndex], (-distSquared, i + 1))  # i + 1 to make indices 1-based (for matlab)
            if len(nns[searchedIndex]) > NUMBER_OF_NNS:
                heapq.heappop(nns[searchedIndex])

        tmp = [heapq.heappop(nns[searchedIndex]) for _ in range(len(nns[searchedIndex]))]
        tmp.reverse()  # reverse because we have max heap
        nns[searchedIndex] = [tmp[k][1] for k in range(len(tmp))]  # neighbour indices
        distances[searchedIndex] = [-tmp[k][0] for k in range(len(tmp))]  # distances to the neighbours
        # print "Size of nns: ", len(nns[searchedIndex])

        if searchedIndex % 100 == 0:
            print "\n%d: Current frameId: %d" %(threadId, searchedIndex)

    filename = "nns_100files_%05d_%05d.mat" % (begin, end);
    print "\n%d: Saving to %s ..." % (threadId, filename)
    scipy.io.savemat(filename, mdict={'nns': nns[begin:end], 'distances': distances[begin:end]})
    print "\n%d: Saved!" % threadId


if __name__ == "__main__":
    startTime = time.time()
    main()
    print("NNs searching was done: %s seconds ---" % (time.time() - startTime))
