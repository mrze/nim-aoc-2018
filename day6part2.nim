import math
import strscans
import sequtils
import strutils
import sets
import tables

type Point = tuple[x: int, y: int]

proc manhattanDistance(a: Point, b: Point): int =
    return abs(a.x - b.x) + abs(a.y - b.y)


proc sumDistances(to: Point, points: seq[Point]): int =
    for p in points:
        result += manhattanDistance(to, p)


proc sumPointsWithinThreshold(points: seq[Point], threshold: int): int =
    var minX = points[0].x;
    var minY = points[0].y;
    var maxX = points[0].x;
    var maxY = points[0].y;

    for p in points:
        minX = min(minX, p.x)
        minY = min(minY, p.y)
        maxX = max(maxX, p.x)
        maxY = max(maxY, p.y)

    # its possible that extra points are required, I figure this is the upperbound max size of the grid
    var extra: int = (int)ceil(threshold / len(points))

    for x in countup(minX - extra, maxX + extra):
        for y in countup(minY - extra, maxY + extra):
            var current: Point = (x: x, y: y)
            if sumDistances(current, points) < threshold:
                result += 1


proc parsePoints(input: string): seq[Point] =
    result = newSeq[Point]()
    for line in input.splitLines():
        var p: Point;
        if(scanf(line, "$i, $i", p.x, p.y)):
            result.add(p)

proc sumPointsWithinThreshold(input: string, threshold: int): int =
    return sumPointsWithinThreshold(parsePoints(input), threshold)

assert(sumPointsWithinThreshold("""1, 1
1, 6
8, 3
3, 4
5, 5
8, 9""", 32) == 16)

echo sumPointsWithinThreshold(readAll(stdin), 10000)