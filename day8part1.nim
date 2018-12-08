import strutils
import sequtils

# metadata visitor callback, called whenever a metadata node is visited
type MetadataCallback = proc(x: int): void


proc readHeader(entries: seq[int], start: int, callback: MetadataCallback): int =
    var index = 0

    var numChildNodes = entries[start+index]
    var numMetadataEntries = entries[start+index+1]
    index += 2

    for i in countup(0, numChildNodes-1):
        index += readHeader(entries, start+index, callback)

    for i in countup(0, numMetadataEntries-1):
        callback(entries[start+index+i])
    index += numMetadataEntries

    return index



proc sumMetadataEntries(entries: seq[int]): int =
    var sum = 0
    discard readHeader(entries, 0, proc(x: int): void =
        sum += x
    )
    return sum


assert(sumMetadataEntries("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split().map(parseInt)) == 138)

echo sumMetadataEntries(stdin.readAll().strip().split().map(parseInt))