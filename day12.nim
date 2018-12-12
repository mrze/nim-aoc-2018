import sequtils
import strutils
import strscans
import tables

type PlantState = TableRef[int64, bool]
type Rules = TableRef[int64, bool]


proc printPlants(plants: PlantState): string =
    for i in countup(min(toSeq(plants.keys())), max(toSeq(plants.keys()))):
        if(plants.hasKey(i) and plants[i]):
            result.add("#")
        else:
            result.add(".")


proc generateSum(plants: PlantState): int64 =
    for position, hasPlant in plants.pairs():
        if hasPlant:
            result += position


proc plantSeqToInt(plants: PlantState, center: int64): int =
    var j = 1
    for i in countup(-2, 2):
        if plants.hasKey(center + i) and plants[center + i]:
            result += j
        j *= 2


proc ruleToInt(input: string): int =
    var x = 1
    for c in input:
        if c == '#':
            result += x
        x *= 2


proc parseInput(input: string): tuple[plants: PlantState, rules: Rules] =
    result.plants = newTable[int64, bool]()
    result.rules = newTable[int64, bool]()

    for line in input.splitlines():
        if(scanf(line, "initial state:")):
            var state = line.split(" ")[2]
            var i = 0
            for c in state:
                if c == '#':
                    result.plants[i] = true
                i += 1
        else:
            var rulestr: string
            var output: string
            (rulestr, output) = line.split(" => ")
            result.rules[ruleToInt(rulestr)] = (output == "#")


proc runGeneration(plants: PlantState, rules: Rules): PlantState =
    result = newTable[int64, bool]()
    for i in countup(min(toSeq(plants.keys())) - 4, max(toSeq(plants.keys())) + 4):
        var value = plants.plantSeqToInt(i)
        if rules.hasKey(value):
            if rules[value]:
                result[i] = rules[value]


proc generations(input: string, generations: int64): PlantState =
    var rules: Rules
    (result, rules) = parseInput(input)

    var start: int64 = 1
    var i: int64
    for i in countup(start, generations):
        result = runGeneration(result, rules)

proc extrapolate(input: string, generations: int64, a: int64, b: int64): int64 =
    var va = generations(input, a).generateSum()
    var vb = generations(input, b).generateSum()
    var delta = (vb - va) div (b - a);

    var v5b = va + ((generations - a) * delta)
    return v5b

assert(ruleToInt(".....") == 0)
assert(ruleToInt("#....") == 1)
assert(ruleToInt(".#...") == 2)
assert(ruleToInt("..#..") == 4)
assert(ruleToInt("#.#.#") == 1+4+16)

var testInput = """initial state: #..#.#..##......###...###
...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #"""

assert(parseInput(testInput).plants.plantSeqToInt(0) == 4)
assert(parseInput(testInput).plants.plantSeqToInt(2) == 1+8)

assert(parseInput(testInput).plants.printPlants() == "#..#.#..##......###...###")

assert(generations(testInput, 0).printPlants() == "#..#.#..##......###...###")
assert(generations(testInput, 1).printPlants() == "#...#....#.....#..#..#..#")

assert(generations(testInput, 20).generateSum() == 325)

var actualInput = stdin.readAll()
echo generations(actualInput, 20).generateSum()
echo extrapolate(actualInput, 50_000_000_000, 10000, 20000)

