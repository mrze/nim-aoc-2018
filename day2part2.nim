import sequtils
import tables

proc countStringCharsDifferent(a: string, b: string): int =
    assert(len(a) == len(b))

    for i in countup(0, len(a) - 1):
        if a[i] != b[i]:
            result += 1


proc stringCharsSame(a: string, b: string): string =
    assert(len(a) == len(b))

    for i in countup(0, len(a) - 1):
        if a[i] == b[i]:
            result.add(a[i])


proc similarity(idents: seq[string]): string =
    for a in idents:
        for b in idents:
            if countStringCharsDifferent(a, b) == 1:
                return stringCharsSame(a, b)


assert(countStringCharsDifferent("abcde", "abcdf") == 1)

assert(similarity(@["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"]) == "fgij")

echo similarity(toSeq(stdin.lines))