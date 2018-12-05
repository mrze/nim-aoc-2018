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


proc analyseWithElementRemoved(polymer: string, element: string): int =
    var reconstructedPolymer = polymer.replace(element.toLowerAscii().re())
                                      .replace(element.toUpperAscii().re())
    return resolvePolymer(reconstructedPolymer)


proc analyseAllElements(polymer: string): int =
    var lowestResult = resolvePolymer(polymer)
    for a in countup('a', 'z'):
        var newResult = analyseWithElementRemoved(polymer, $a)
        lowestResult = min(lowestResult, newResult)
    return lowestResult


assert(analyseAllElements("dabAcCaCBAcCcaDA") == 4)
assert(analyseAllElements("aAbBcCdDDdEe") == 0)

var input = readAll(stdin).strip()
echo analyseAllElements(input)
