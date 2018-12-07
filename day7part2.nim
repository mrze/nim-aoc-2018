import strscans
import sequtils
import strutils
import sets
import tables

type ReqsTable = TableRef[char, HashSet[char]]
type RemainingTime = TableRef[char, int]


proc calculateTaskTimeQuick(input: char): int =
    return (ord(input) - ord('A') + 1)


proc calculateTaskTimeNormal(input: char): int =
    return 60 + (ord(input) - ord('A') + 1)


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


proc nextRequirement(requirements: ReqsTable): HashSet[char] =
    result = initSet[char]()
    var next: char
    for c, r in requirements.pairs:
        if len(r) == 0:
            result.incl(c)


proc resolveStepsParallel(input: string, maxWorkers: int, taskTimer:  proc (input: char): int): int =
    var orders = ""
    var requirements = generateRequirements(input)

    var timeSpent = 0
    var remainingTime = newTable[char, int]()
    for c in requirements.keys:
        remainingTime[c] = taskTimer(c)

    var runningSteps: HashSet[char] = initSet[char]()

    while len(requirements) > 0:
        # work out runnable tasks
        var next = nextRequirement(requirements)

        # add tasks for remaining workers
        for n in next:
            if len(runningSteps) < maxWorkers:
                runningSteps.incl(n)

        # work out minimum timeslice
        var howLongSpent = 99
        for n in runningSteps:
            howLongSpent = min(howLongSpent, remainingTime[n])
        timeSpent += howLongSpent

        # for everything that is running
        for n in runningSteps:
            # spend time on task
            remainingTime[n] -= howLongSpent

            # if task is finished
            if remainingTime[n] == 0:
                # clean up from remaining time
                remainingTime.del(n)

                # remove from running tasks
                runningSteps.excl(n)

                # clean up requirements
                requirements.del(n)
                for c, r in requirements.mpairs:
                    r.excl(n)

    return timeSpent



assert(calculateTaskTimeQuick('A') == 1)
assert(calculateTaskTimeNormal('A') == 61)
assert(calculateTaskTimeNormal('Z') == 86)

assert(resolveStepsParallel("""Step C must be finished before step A can begin.""", 1, calculateTaskTimeQuick) == 4)

assert(resolveStepsParallel("""Step A must be finished before step C can begin.
Step A must be finished before step C can begin.""", 2, calculateTaskTimeQuick) == 4)

assert(resolveStepsParallel("""Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.""", 2, calculateTaskTimeQuick) == 15)

echo resolveStepsParallel(readAll(stdin), 5, calculateTaskTimeNormal)