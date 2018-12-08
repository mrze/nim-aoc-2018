import strutils
import sequtils
import tables

type MetadataCallback = proc(x: int): void

proc readHeader(entries: seq[int], start: int, value: var int): int =
    # value will have evaluated value for this node returned out

    var index = 0

    # read children count
    var numChildNodes = entries[start+index]

    # read metadata count
    var numMetadataEntries = entries[start+index+1]
    index += 2

    # store evaluated children values in this table
    var childValues: Table[int, int] = initTable[int, int]()

    # for each child, store their evaluated value into the table
    for i in countup(1, numChildNodes):
        var childValue: int;
        index += readHeader(entries, start+index, childValue)
        childValues[i] = childValue

    # for each metadata
    for i in countup(0, numMetadataEntries-1):
        var metadata = entries[start + index + i]

        if numChildNodes == 0:
            # if there are no children, then the value is just the sum
            value += metadata
        else:
            # if there are children, then the value is a child lookup based on metadata index
            if metadata >= 1 and metadata <= numChildNodes:
                value += childValues[metadata]
    index += numMetadataEntries

    return index



proc sumLinkedMetadataEntries(entries: seq[int]): int =
    var rootValue: int
    discard readHeader(entries, 0, rootValue)
    return rootValue


assert(sumLinkedMetadataEntries("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split().map(parseInt)) == 66)

echo sumLinkedMetadataEntries(stdin.readAll().strip().split().map(parseInt))