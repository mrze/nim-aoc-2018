import sets
import sequtils
import strscans
import system

type Claim = tuple[id: int, x: int, y: int, width: int, height: int]
type Point = tuple[x: int, y: int]



proc countCollidingClaims(claims: seq[Claim]): int =
    var claimed = initSet[Point]()
    var duplicates = initSet[Point]()

    for claim in claims:
        for x in countup(claim.x, claim.x + claim.width - 1):
            for y in countup(claim.y, claim.y + claim.height - 1):
                var p: Point = (x, y)
                if claimed.contains(p):
                    duplicates.incl(p)
                claimed.incl(p)
    return duplicates.len

proc parseClaim(claimStr: string): Claim =
    if scanf(claimStr, "#$i @ $i,$i: $ix$i", result.id, result.x, result.y, result.width, result.height):
        return result

proc countCollidingClaims(claims: seq[string]): int =
    return countCollidingClaims(claims.map(parseClaim))


assert(countCollidingClaims(@["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]) == 4);

echo countCollidingClaims(toSeq(stdin.lines))
