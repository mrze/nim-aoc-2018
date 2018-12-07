import strscans
import sequtils
import strutils
import sets
import tables

type ReqsTable = TableRef[char, HashSet[char]]


proc generateRequirements(input: string): ReqsTable =
    result = newTable[char, HashSet[char]]()

    for line in input.splitLines():
        var current, requires: string;
        if scanf(line, "Step $w must be finished before step $w can begin.", requires, current):
            var c = current[0]
            var r = requires[0]

            if not result.hasKey(r):
                result[r] = initSet[char]()
            if not result.hasKey(c):
                result[c] = initSet[char]()
            result[c].incl(requires[0])


proc nextRequirement(requirements: ReqsTable): char =
    var next: char
    for c, r in requirements.pairs:
        if len(r) == 0:
            next = c
            break

    requirements.del(next)

    for c, r in requirements.mpairs:
        r.excl(next)

    return next




proc resolveSteps(input: string): string =
    var orders = ""
    var requirements = generateRequirements(input)

    while len(requirements) > 0:
        var next = nextRequirement(requirements)
        orders.add(next)

    return orders




assert(resolveSteps("""Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.""") == "CABDFE")

echo resolveSteps(readAll(stdin))