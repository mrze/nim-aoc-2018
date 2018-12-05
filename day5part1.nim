import streams
import strutils
import re


proc generateRemovalRegex(): Regex =
    var adjacentCharactersRex: seq[string] = @[];
    for a in countup('a', 'z'):
        adjacentCharactersRex.add(a.toLowerAscii() & a.toUpperAscii())
        adjacentCharactersRex.add(a.toUpperAscii() & a.toLowerAscii())
    return adjacentCharactersRex.join("|").re()


proc resolvePolymer(polymer: string): int =
    var currentPolymer = polymer

    var regex = generateRemovalRegex()

    var changed = true
    while changed:
        var nextPolymer = currentPolymer.replace(regex, "")
        changed = (currentPolymer != nextPolymer)
        currentPolymer = nextPolymer

    return len(currentPolymer)


assert(resolvePolymer("dabAcCaCBAcCcaDA") == 10)
assert(resolvePolymer("aAbBcCdDDdEe") == 0)

var input = readAll(stdin).strip()
echo resolvePolymer(input)
