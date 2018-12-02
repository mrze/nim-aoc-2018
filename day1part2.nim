import sets
import sequtils
import strutils


proc findRepeat(freqs: seq[int]): int =
    var total: int = 0
    var seen = initSet[int]()
    seen.incl(0)

    while true:
        for freq in freqs:
            total += freq

            if seen.contains(total):
                return total
            seen.incl(total)

proc readNumbersFromStdin(): seq[int] =
    return toSeq(stdin.lines).map(parseInt)


assert(findRepeat(@[1, -2, 3, 1]) == 2)
assert(findRepeat(@[1, -1]) == 0)
assert(findRepeat(@[3, 3, 4, -2, -4]) == 10)
assert(findRepeat(@[-6, 3, 8, 5, -6]) == 5)
assert(findRepeat(@[7, 7, -2, -7, -4]) == 14)

echo findRepeat(readNumbersFromStdin())

