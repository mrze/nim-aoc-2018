
type Point = tuple[x: int, y: int]
type PointWithPower = tuple[point: Point, power: int]


proc powerGridPoint(topLeft: Point, serial: int): int =
    var rackID = topLeft.x + 10
    var powerLevel = rackID * topLeft.y
    powerLevel += serial
    powerLevel *= rackID
    var hundreds: int = (powerLevel mod 1000) div 100
    return hundreds - 5

proc powerGrid3by3(topLeft: Point, serial: int): int =
    for x in countup(0, 2):
        for y in countup(0, 2):
            result += powerGridPoint((x: topLeft.x + x, y: topLeft.y + y), serial)


proc powerGridFindMax(serial: int): PointWithPower =
    for x in countup(1, 298):
        for y in countup(1, 298):
            var point = (x: x, y: y)
            var power = powerGrid3by3(point, serial)
            if power > result.power:
                result.power = power
                result.point = point


assert(powerGridPoint((x: 3, y: 5), 8) == 4)
assert(powerGridPoint((x: 122, y: 79), 57) == -5)
assert(powerGridPoint((x: 217, y: 196), 39) == 0)
assert(powerGridPoint((x: 101, y: 153), 71) == 4)


assert(powerGrid3by3((x: 33, y: 45), 18) == 29)

assert(powerGridFindMax(18) == (point: (x: 33, y: 45), power: 29))
assert(powerGridFindMax(42) == (point: (x: 21, y: 61), power: 30))

echo powerGridFindMax(7689)
