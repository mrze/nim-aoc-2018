import algorithm
import strutils

type State = ref object
    scores: seq[int]
    firstLocation: int
    secondLocation: int

proc `$`(s: State): string =
    for index, value in s.scores.pairs:
        result.add(value)


proc initState(): State =
    result = new State
    result.scores = @[3, 7]
    result.firstLocation = 0
    result.secondLocation = 1


proc individualDigits(n: int): seq[int] =
    assert n >= 0
    assert n <= 18

    if n == 0:
        return @[0]

    var current = n
    while current > 0:
        result.add(current mod 10)
        current = current div 10
    result.reverse()


proc runStep(state: State): State =
    var recipeSum = state.scores[state.firstLocation] + state.scores[state.secondLocation]

    for digit in individualDigits(recipeSum):
        assert digit >= 0
        assert digit <= 9
        state.scores.add(digit)

    state.firstLocation += 1 + state.scores[state.firstLocation]
    state.firstLocation = state.firstLocation mod len(state.scores)

    state.secondLocation += 1 + state.scores[state.secondLocation]
    state.secondLocation = state.secondLocation mod len(state.scores)

    return state


proc runStep(state: State, requiredLength: int): State =
    var current = state
    while len(current.scores) < requiredLength:
        current = current.runStep()
    return current


# super lazy solution: represent as string,
# figure out an upperbound to generate
# use string find to search for needle
proc search(state: State, upperBound: int, needle: string): int =
    var s = runStep(state, upperBound)
    var haystack = $s
    return haystack.find(needle)


assert(initState().search(1000000, "51589") == 9)
assert(initState().search(1000000, "01245") == 5)
assert(initState().search(1000000, "92510") == 18)
assert(initState().search(1000000, "59414") == 2018)

echo initState().search(100000000, "864801")