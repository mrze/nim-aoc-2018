import sets
import sequtils
import strscans
import system
import tables

type Claim = tuple[id: int, x: int, y: int, width: int, height: int]
type Point = tuple[x: int, y: int]


iterator listPoints(claim: Claim): Point =
    for x in countup(claim.x, claim.x + claim.width - 1):
        for y in countup(claim.y, claim.y + claim.height - 1):
            yield (x, y)


proc findNonCollidingClaims(claims: seq[Claim]): int =
    var claimed = initSet[Point]()
    var duplicates = initSet[Point]()

    for claim in claims:
        for point in claim.listPoints():
            if point in claimed:
                duplicates.incl(point)
            claimed.incl(point)

    for claim in claims:
        var hitDuplicate = false
        for point in claim.listPoints():
            if point in duplicates:
                hitDuplicate = true
        if not hitDuplicate:
            return claim.id


proc parseClaim(claimStr: string): Claim =
    if scanf(claimStr, "#$i @ $i,$i: $ix$i", result.id, result.x, result.y, result.width, result.height):
        return result


proc findNonCollidingClaims(claims: seq[string]): int =
    return findNonCollidingClaims(claims.map(parseClaim))


assert(findNonCollidingClaims(@["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 3);

echo findNonCollidingClaims(toSeq(stdin.lines).map(parseClaim))
