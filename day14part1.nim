import algorithm
import strutils

type State = ref object
    scores: seq[int]
    firstLocation: int
    secondLocation: int

proc `$`(s: State): string =
    for index, value in s.scores.pairs:
        if s.firstLocation == index and s.secondLocation == index:
            result.add("([")
            result.add(value)
            result.add("])")
        elif s.firstLocation == index:
            result.add("(")
            result.add(value)
            result.add(")")
        elif s.secondLocation == index:
            result.add("[")
            result.add(value)
            result.add("]")
        else:
            result.add(value)
        result.add(" ")


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

proc tenAfter(state: State, n: int): int64 =
    var current = state.runStep(n + 10)

    for i in countup(n, n+9):
        result = result * 10 + current.scores[i]


assert(individualDigits(0) == [0])
assert(individualDigits(7) == [7])
assert(individualDigits(10) == [1, 0])
assert(individualDigits(15) == [1, 5])

assert(initState().tenAfter(9) == 5158916779)
assert(initState().tenAfter(5) == 0124515891)
assert(initState().tenAfter(18) == 9251071085)
assert(initState().tenAfter(2018) == 5941429882)

echo initState().tenAfter(864801)
