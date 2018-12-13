import algorithm
import sequtils
import sets
import strutils
import tables


type Direction = enum
    LEFT,
    STRAIGHT,
    RIGHT


type Compass = enum
    NORTH,
    EAST,
    SOUTH,
    WEST


type Point = tuple[x: int, y: int]


type Cart = ref object
    location: Point
    vector: Compass
    nextDirection: Direction
    deleted: bool


type Track = ref object
    raw: char


type Map = ref object
    maxX: int
    maxY: int

    tracks: TableRef[Point, Track]
    carts: seq[Cart]

    crashes: seq[Point]


proc cmp(a: Cart, b: Cart): int =
    if a.location.y < b.location.y:
        return -1
    if a.location.y > b.location.y:
        return 1
    if a.location.x < b.location.x:
        return -1
    if a.location.x > b.location.x:
        return 1
    return 0


proc `+`(a: Point, b: Point): Point =
    return (x: a.x + b.x, y: a.y + b.y)


proc `+`(a: Compass, b: Direction): Compass =
    if b == STRAIGHT:
        return a

    if a == NORTH and b == LEFT:
        return WEST
    if a == NORTH and b == RIGHT:
        return EAST

    if a == SOUTH and b == LEFT:
        return EAST
    if a == SOUTH and b == RIGHT:
        return WEST

    if a == EAST and b == LEFT:
        return NORTH
    if a == EAST and b == RIGHT:
        return SOUTH

    if a == WEST and b == LEFT:
        return SOUTH
    if a == WEST and b == RIGHT:
        return NORTH

proc toUnitVector(direction: Compass): Point =
    case direction:
        of NORTH:
            return (x: 0, y: -1)
        of SOUTH:
            return (x: 0, y: 1)
        of EAST:
            return (x: 1, y: 0)
        of WEST:
            return (x: -1, y: 0)


proc `+`(p: Point, direction: COMPASS): Point =
    return p + direction.toUnitVector()


proc next(a: Direction): Direction =
    case a:
        of LEFT:
            return STRAIGHT
        of STRAIGHT:
            return RIGHT
        of RIGHT:
            return LEFT


proc markCrashes(map: Map): HashSet[Point] =
    var cartsCount: CountTable[Point] = initCountTable[Point]()
    for cart in map.carts:
        if not cart.deleted:
            cartsCount.inc(cart.location)

    var crashesAt: HashSet[Point] = initSet[Point]()
    for point, count in cartsCount:
        if count > 1:
            crashesAt.incl(point)

    for cart in map.carts:
        if not cart.deleted and cartsCount[cart.location] > 1:
            cart.deleted = true

    return crashesAt


proc parseMap(input: string): Map =
    result = new Map
    result.tracks = newTable[Point, Track]()
    result.carts = newSeq[Cart]()

    var x = 0
    var y = 0

    for line in input.splitLines():
        x = 0
        for c in line:
            if c == ' ':
                discard
            else:
                var p: Point = (x: x, y: y)

                var t: Track = new Track
                t.raw = c
                result.tracks[p] = t

                result.maxX = max(result.maxX, x)
                result.maxY = max(result.maxY, y)
            x += 1
        y += 1

    # work out location of carts and their starting direction
    for p, track in result.tracks.pairs:
        if track.raw == '^' or track.raw == 'v' or track.raw == '>' or track.raw == '<':
            var cart: Cart = new Cart
            cart.location = p
            cart.nextDirection = LEFT

            if track.raw == '^':
                track.raw = '|'
                cart.vector = NORTH
            elif track.raw == 'v':
                track.raw = '|'
                cart.vector = SOUTH
            elif track.raw == '>':
                track.raw = '-';
                cart.vector = EAST
            elif track.raw == '<':
                track.raw = '-';
                cart.vector = WEST

            result.carts.add(cart)


proc runTick(map: Map): Map =
    result = new Map
    result.maxX = map.maxX
    result.maxY = map.maxY
    result.tracks = map.tracks

    result.carts = map.carts
    result.crashes = map.crashes

    # carts are processed in order of position, top to bottom
    result.carts.sort(cmp)

    for cart in map.carts:
        if cart.deleted:
            continue

        var track = map.tracks[cart.location]

        var nextLocation: Point
        var nextVector: Compass
        var nextDirection: Direction = cart.nextDirection

        if track.raw == '+':
            nextVector = cart.vector + cart.nextDirection
            nextLocation = cart.location + nextVector
            nextDirection = next(cart.nextDirection)

        elif track.raw == '-' or track.raw == '|':
            nextVector = cart.vector
            nextLocation = cart.location + nextVector

        elif track.raw == '/':
            case cart.vector:
                of NORTH:
                    nextVector = EAST
                of EAST:
                    nextVector = NORTH
                of SOUTH:
                    nextVector = WEST
                of WEST:
                    nextVector = SOUTH
            nextLocation = cart.location + nextVector

        elif track.raw == '\\':
            case cart.vector:
                of NORTH:
                    nextVector = WEST
                of WEST:
                    nextVector = NORTH
                of SOUTH:
                    nextVector = EAST
                of EAST:
                    nextVector = SOUTH
            nextLocation = cart.location + nextVector

        else:
            assert(false)

        cart.location = nextLocation
        cart.vector = nextVector
        cart.nextDirection = nextDirection

        for crashLocation in markCrashes(map).items:
            result.crashes.add(crashLocation)

    # remove any carts marked as deleted
    result.carts.keepIf(proc (c: Cart): bool = not c.deleted)


proc countRemainingCarts(map: Map): int =
    for cart in map.carts:
        result += 1


proc runTicks(map: Map, ticks: int): Map =
    result = map
    for i in countup(1, ticks):
        result = runTick(result)

proc remainingCartLocation(map: Map): Point =
    assert(countRemainingCarts(map) == 1)
    for cart in map.carts:
        return cart.location


proc runUntilOneCartRemains(map: Map): Map =
    var current = map
    while countRemainingCarts(current) > 1:
        current = runTick(current)
    return current


var simpleMap = """
/>-<\
|   |
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/
""".strip()
assert(parseMap(simpleMap).runUntilOneCartRemains().remainingCartLocation() == (x: 6, y: 4))

var map = readAll(stdin).parseMap().runUntilOneCartRemains()
echo map.crashes
echo map.remainingCartLocation()
