import strutils
import strscans
import sets
import streams


type Vector2 = tuple[x: int, y: int]
type Particle = tuple[loc: Vector2, velocity: Vector2]


proc min(a: Vector2, b: Vector2): Vector2 =
    result.x = min(a.x, b.x)
    result.y = min(a.y, b.y)


proc max(a: Vector2, b: Vector2): Vector2 =
    result.x = max(a.x, b.x)
    result.y = max(a.y, b.y)


proc `*`(a: Vector2, b: int): Vector2 =
    result.x = a.x * b
    result.y = a.y * b


proc `-`(a: Vector2, b: Vector2): Vector2 =
    result.x = a.x - b.x
    result.y = a.y - b.y


proc `+`(a: Vector2, b: Vector2): Vector2 =
    result.x = a.x + b.x
    result.y = a.y + b.y


iterator parseParticles(input: string): Particle =
    for line in input.splitLines():
        var p: Particle
        if scanf(line.replace(" ", ""), "position=<$i,$i>velocity=<$i,$i>", p.loc.x, p.loc.y, p.velocity.x, p.velocity.y):
            yield p


proc translate(particle: Particle, t: int): Vector2 =
    return particle.loc + (particle.velocity * t)


iterator translate(input: string, t: int): Vector2 =
    for particle in parseParticles(input):
        yield translate(particle, t)


proc printGrid(min: Vector2, max: Vector2, points: HashSet[Vector2]): void =
    for y in countup(min.y, max.y):
        for x in countup(min.x, max.x):
            var p: Vector2 = (x: x, y: y)
            if p in points:
                stdout.write '#'
            else:
                stdout.write '.'
        stdout.write "\n"

proc displayMessage(input: string, t: int, maxX: int, maxY: int): bool =
    var points: HashSet[Vector2] = initSet[Vector2]()

    var boundsMin: Vector2
    var boundsMax: Vector2
    var bounds: Vector2

    var first = true
    for translated in translate(input, t):
        if first:
            boundsMin = translated
            boundsMax = translated
            first = false

        boundsMin = min(boundsMin, translated)
        boundsMax = max(boundsMax, translated)
        points.incl(translated)

        var bounds = boundsMax - boundsMin
        if bounds.x > maxX or bounds.y > maxY:
            return false

    printGrid(boundsMin, boundsMax, points)
    return true


assert(displayMessage("""position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>""", 3, 500, 10))


var input = stdin.readAll()
for t in countup(10000, 10100, 1):
    if displayMessage(input, t, 500, 15):
        break