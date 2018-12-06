import strscans
import sequtils
import strutils
import sets
import tables

type Point = tuple[x: int, y: int]
type NamedPoint = tuple[id: int, point: Point]


proc manhattanDistance(a: Point, b: Point): int =
    return abs(a.x - b.x) + abs(a.y - b.y)


proc closestPoint(to: Point, points: seq[NamedPoint]): int =
    var closestDistance = manhattanDistance(to, points[0].point);
    var closestID = points[0].id;

    for p in points:
        var currentDistance = manhattanDistance(to, p.point)
        if currentDistance < closestDistance:
            closestDistance = currentDistance
            closestID = p.id
        elif currentDistance == closestDistance and closestID != p.id:
            closestID = -1

    return closestID


proc pointFurthestAway(points: seq[NamedPoint]): int =
    var minX = points[0].point.x;
    var minY = points[0].point.y;
    var maxX = points[0].point.x;
    var maxY = points[0].point.y;

    for p in points:
        minX = min(minX, p.point.x)
        minY = min(minY, p.point.y)
        maxX = max(maxX, p.point.x)
        maxY = max(maxY, p.point.y)

    var closest: Table[Point, int] = initTable[Point, int]()

    # for each point within the grid, work out the closest named point to it,
    # or -1 if there are multiple
    for x in countup(minX, maxX):
        for y in countup(minY, maxY):
            var current: Point = (x: x, y: y)
            closest[current] = closestPoint(current, points)

    var idCounter: CountTable[int] = initCountTable[int]()
    for id in closest.values():
        idCounter.inc(id)

    # Try to cull points that expand beyond the borders infinitely
    var infinite = initSet[int]()
    infinite.incl(-1)

    for x in countup(minX, maxX):
        infinite.incl(closestPoint((x: x, y: minY - 1), points))
        infinite.incl(closestPoint((x: x, y: maxY + 1), points))
    for y in countup(minY, maxY):
        infinite.incl(closestPoint((x: minX - 1, y: y), points))
        infinite.incl(closestPoint((x: maxX + 1, y: y), points))

    # return first non infinite value
    idCounter.sort()
    for id, count in idCounter:
        if not infinite.contains(id):
            return count


proc parsePoints(input: string): seq[NamedPoint] =
    result = newSeq[NamedPoint]()
    var i = 1
    for line in input.splitLines():
        var p: NamedPoint;
        if(scanf(line, "$i, $i", p.point.x, p.point.y)):
            p.id = i
            result.add(p)
            i += 1

proc pointFurthestAway(input: string): int =
    return pointFurthestAway(parsePoints(input))

assert(pointFurthestAway("""1, 1
1, 6
8, 3
3, 4
5, 5
8, 9""") == 17)

echo pointFurthestAway(readAll(stdin))