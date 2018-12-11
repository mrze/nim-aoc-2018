import tables

type Point = tuple[x: int, y: int]
type TLRectangle = tuple[bottomRight: Point]
type Rectangle = tuple[topLeft: Point, bottomRight: Point]
type Square = tuple[topLeft: Point, size: int]
type SquareWithPower = tuple[square: Square, power: int]
type RectTotals = TableRef[TLRectangle, int]


proc `-`(rect: TLRectangle, point: Point): TLRectangle =
    result.bottomRight.x = rect.bottomRight.x - point.x
    result.bottomRight.y = rect.bottomRight.y - point.y


proc toRect(square: Square): Rectangle =
    return (topLeft: square.topLeft,
            bottomRight: (x: square.topLeft.x + square.size - 1,
                          y: square.topLeft.y + square.size - 1))


# Raw calculation for individual point
proc powerGridPoint(topLeft: Point, serial: int): int =
    var rackID = topLeft.x + 10
    var powerLevel = rackID * topLeft.y
    powerLevel += serial
    powerLevel *= rackID
    var hundreds: int = (powerLevel mod 1000) div 100
    return hundreds - 5


# Work out sum for a given square by converting it into 4 rectangles originating at (1,1)
# total sum = (1,1 to x2,y2) - (1,1 to x1,y2) - (1,1 to x2,y1) + (1,1 to x1,y1)
# this avoids us having to calculate the sum of all the points each time
proc powerGridTotal(totals: RectTotals, square: Square): int =
    var rect = square.toRect()

    var overall = (bottomRight: rect.bottomRight)
    var a = totals.getOrDefault(overall, 0)

    var topOverlap = (bottomRight: (x: rect.bottomRight.x, y: rect.topLeft.y - 1))
    var b = totals.getOrDefault(topOverlap, 0)

    var leftOverlap = (bottomRight: (x: rect.topLeft.x - 1, y: rect.bottomRight.y))
    var c = totals.getOrDefault(leftOverlap, 0)

    var topLeftOverlap = (bottomRight: (x: rect.topLeft.x - 1, y: rect.topLeft.y - 1))
    var d = totals.getOrDefault(topLeftOverlap, 0)

    result = a - b - c + d


# Translates lookup for individual points into unit sized square lookup
proc powerGridTotal(totals: RectTotals, point: Point): int =
    var square: Square = (topLeft: point, size: 1)
    return powerGridTotal(totals, square)


# Finds the highest power square for a given size
proc findHighestPowerSquare(grid: RectTotals, size: int): SquareWithPower =
    for x in countup(1, 300 - size):
        for y in countup(1, 300 - size):
            var square: Square = (topLeft: (x: x, y: y), size: size)
            var power = powerGridTotal(grid, square)
            if power > result.power:
                result.power = power
                result.square = square


# Finds biggest sized square
proc biggestSquare(grid: RectTotals): SquareWithPower =
    for size in countup(1, 300):
        var found = findHighestPowerSquare(grid, size)
        if found.power > result.power:
            result = found


# Generates power total sums, sum is all points from (1,1) to (x,y)
proc generatePowerGrid(serial: int): RectTotals =
    result = newTable[TLRectangle, int]()
    for x in countup(1, 300):
        for y in countup(1, 300):
            var rect: TLRectangle = (bottomRight: (x: x, y: y))
            var total = 0
            total += result.getOrDefault(rect - (x: 1, y: 0), 0)
            total += result.getOrDefault(rect - (x: 0, y: 1), 0)
            total += powerGridPoint(rect.bottomRight, serial)
            total -= result.getOrDefault(rect - (x: 1, y: 1), 0)
            result[rect] = total


assert(powerGridPoint((x: 1, y: 1), 8) == -3)
assert(generatePowerGrid(8).powerGridTotal((x: 1, y: 1)) == -3)
assert(powerGridPoint((x: 3, y: 5), 8) == 4)
assert(generatePowerGrid(8).powerGridTotal((x: 3, y: 5)) == 4)
assert(generatePowerGrid(57).powerGridTotal((x: 122, y: 79)) == -5)
assert(generatePowerGrid(39).powerGridTotal((x: 217, y: 196)) == 0)
assert(generatePowerGrid(71).powerGridTotal((x: 101, y: 153)) == 4)


assert(generatePowerGrid(18).powerGridTotal((topLeft: (x: 33, y: 45), size: 3)) == 29)
assert(generatePowerGrid(18).findHighestPowerSquare(3) == (square: (topLeft: (x: 33, y: 45), size: 3), power: 29))

assert(generatePowerGrid(18).biggestSquare() == (square: (topLeft: (x: 90, y: 269), size: 16), power: 113))
assert(generatePowerGrid(42).biggestSquare() == (square: (topLeft: (x: 232, y: 251), size: 12), power: 119))

echo biggestSquare(generatePowerGrid(7689))
