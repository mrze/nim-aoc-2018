import strscans
import strutils
import sequtils
import sets

const MAX_GRID = 2000


type Point = tuple[x: int, y: int]
const UP = (x: 0, y: -1)
const DOWN = (x: 0, y: 1)
const LEFT = (x: -1, y: 0)
const RIGHT = (x: 1, y: 0)


type Material = enum
    EMPTY,
    CLAY,
    WATER,
    STREAM


type GridBounds = tuple[xMin: int, xMax: int, yMin: int, yMax: int]


type Map = ref object
    bounds: GridBounds
    grid: array[0..MAX_GRID, array[0..MAX_GRID, Material]]
    water: HashSet[Point]


func `+`(a: Point, b: Point): Point =
    return (x: a.x + b.x, y: a.y + b.y)


func `+=`(a: var Point, b: Point) =
    a.x += b.x
    a.y += b.y


iterator `range`(a: Point, b: Point): Point =
    assert(a.y == b.y)
    for x in a.x..b.x:
        yield (x: x, y: a.y)


func inBounds(p: Point, bounds: GridBounds): bool =
    # note: does not check if above yMin, because of how the spring works
    return p.x >= bounds.xMin and p.x <= bounds.xMax and
           p.y <= bounds.yMax


func `[]`(map: Map, point: Point): Material =
    return map.grid[point.x][point.y]


func parseMap(input: string): Map =
    result = new Map
    result.bounds.xMin = MAX_GRID
    result.bounds.yMin = MAX_GRID

    result.water = initSet[Point]()
    result.water.incl((x: 500, y: 0))

    for line in input.splitLines():
        var xRangeMin: int
        var xRangeMax: int
        var yRangeMin: int
        var yRangeMax: int

        if scanf(line.strip(), "x=$i, y=$i..$i", xRangeMin, yRangeMin, yRangeMax):
            xRangeMax = xRangeMin
        elif scanf(line.strip(), "y=$i, x=$i..$i", yRangeMin, xRangeMin, xRangeMax):
            yRangeMax = yRangeMin
        else:
            continue

        for x in xRangeMin..xRangeMax:
            for y in yRangeMin..yRangeMax:
                result.grid[x][y] = CLAY

                # x is infinite, unlike y
                result.bounds.xMin = min(result.bounds.xMin, x-1)
                result.bounds.xMax = max(result.bounds.xMax, x+1)

                result.bounds.yMin = min(result.bounds.yMin, y)
                result.bounds.yMax = max(result.bounds.yMax, y)


proc printMap(map: Map): string =
    for y in map.bounds.yMin .. map.bounds.yMax:
        for x in map.bounds.xMin .. map.bounds.xMax:
            case map.grid[x][y]:
                of EMPTY:
                    result.add(".")
                of CLAY:
                    result.add("#")
                of WATER:
                    result.add("~")
                of STREAM:
                    result.add("|")
        result.add("\n")
    result.add("\n")


proc checkWalls(map: Map, current: Point): bool =
    var l = current
    var r = current

    # find left/right stream bounds
    while map[l+LEFT] == STREAM:
        l += LEFT
    while map[r+RIGHT] == STREAM:
        r += RIGHT

    # do we have left/right bounding walls?
    if not (map[l+LEFT] == CLAY and map[r+RIGHT] == CLAY):
        return false

    # do we have bottom bounding floor?
    for p in range(l, r):
        var d = map[p+DOWN]
        if d != WATER and d != CLAY:
            return false

    # fill in water, queue any streams above us to be settled
    for p in range(l, r):
        map.grid[p.x][p.y] = WATER

        if map[p+UP] == STREAM:
            map.water.incl(p+UP)

    return true



proc settleWaterOnce(map: Map): void =
    var current: Point = map.water.pop()

    # cannot expand water here
    if map[current] == CLAY or map[current] == WATER:
        return

    # this square becomes reachable running water
    map.grid[current.x][current.y] = STREAM

    # can we turn this square into a pool of water?
    # (if we are surrounded by walls/water)
    discard checkWalls(map, current)

    # expand down
    var d = current + DOWN
    if not d.inBounds(map.bounds):
        return
    map.water.incl(d)

    # expand left/right if we have something below us
    if map[d] == CLAY or map[d] == WATER:
        var l = current + LEFT
        if l.inBounds(map.bounds) and map[l] == EMPTY:
            map.water.incl(l)

        var r = current + RIGHT
        if r.inBounds(map.bounds) and map[r] == EMPTY:
            map.water.incl(r)


proc settleWater(map: Map): void =
    while map.water.len > 0:
        settleWaterOnce(map)


proc countAllWater(map: Map): int =
    for y in map.bounds.yMin .. map.bounds.yMax:
        for x in map.bounds.xMin .. map.bounds.xMax:
            if map.grid[x][y] == WATER or map.grid[x][y] == STREAM:
                result += 1


proc countRetainedWater(map: Map): int =
    for y in map.bounds.yMin .. map.bounds.yMax:
        for x in map.bounds.xMin .. map.bounds.xMax:
            if map.grid[x][y] == WATER:
                result += 1


proc tests(): void =
    var testInput: string
    var map: Map

    testInput = """x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504"""
    map = parseMap(testInput)
    map.settleWater()
    echo map.printMap()
    assert(map.countAllWater() == 57)
    assert(map.countRetainedWater() == 29)

    testInput = """x=495, y=2..7
    y=7, x=497..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504"""
    map = parseMap(testInput)
    map.settleWater()
    echo map.printMap()
    assert(map.countAllWater() == 17)
    assert(map.countRetainedWater() == 0)


    testInput = readFile("day17.input")
    map = parseMap(testInput)
    map.settleWater()
    echo map.printMap()
    echo(map.countAllWater())
    echo(map.countRetainedWater())

tests()