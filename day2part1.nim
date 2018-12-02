import sequtils
import tables

proc checksum(idents: seq[string]): int =
    var twos = 0
    var threes = 0

    for ident in idents:
        var letterCounts: CountTable[char] = initCountTable[char]()
        for c in ident:
            letterCounts.inc(c)

        var hasTwos = false
        var hasThrees = false
        for letter, count in letterCounts.pairs():
            if count == 2:
                hasTwos = true
            if count == 3:
                hasThrees = true

        if hasTwos:
            twos += 1
        if hasThrees:
            threes += 1

    return twos * threes


assert(checksum(@["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"]) == 12)

echo checksum(toSeq(stdin.lines))