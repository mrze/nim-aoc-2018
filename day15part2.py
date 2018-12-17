import math
import sys
from collections import OrderedDict, defaultdict


BASE_ATTACK = 3
STARTING_HP = 200
TEAM_GOBLIN = 1
TEAM_ELVES = 2


class Mob:
    def __init__(self, team, location, dmg):
        self.dmg = dmg
        self.hp = STARTING_HP
        self.team = team
        self.location = location

    def __str__(self):
        if self.team == TEAM_ELVES:
            return 'Elf at ' + repr(self.location) + ' at ' + str(self.hp) + " HP"
        else:
            return 'Goblin at ' + repr(self.location) + ' at ' + str(self.hp) + " HP"


class Map:
    def __init__(self):
        self.max = 0
        self.open_areas = set()
        self.mobs = set()

    def printMap(self, overlay = None):
        if overlay is None:
            overlay = {}

        out = ""
        for y in range(0, self.max):
            eol_stats = []
            for x in range(0, self.max):
                if (x, y) in overlay:
                    if overlay[(x, y)] > 9:
                        out += "%"
                    else:
                        out += str(overlay[(x, y)])
                else:
                    mob = self.mobAtLocation((x, y))
                    if mob:
                        if mob.team == TEAM_GOBLIN:
                            out += "G"
                            eol_stats.append("G("+str(mob.hp)+")")
                        else:
                            out += "E"
                            eol_stats.append("E("+str(mob.hp)+")")

                    elif (x, y) in self.open_areas:
                        out += "."
                    else:
                        out += "#"
            if eol_stats:
                out += " " + ", ".join(eol_stats)
            out += "\n"
        return out


    def __str__(self):
        return self.printMap()


    def countTeams(self):
        """Returns surviving team sizes as dict"""
        teams = defaultdict(int)
        for mob in self.mobs:
            teams[mob.team] += 1
        return teams

    def hitpointSum(self):
        """Returns sum of hitpoints on surviving mobs"""
        return sum(mob.hp for mob in self.mobs)

    def enemyMobs(self, mob):
        """Iterates all enemies on map that are enemies of `mob`"""
        for enemy in self.mobs:
            if enemy.team != mob.team:
                yield enemy


    def mobsByLocation(self):
        """Iterates all mobs on map by reading order location"""
        result = sorted(self.mobs,
                        key=lambda mob: mob.location[0] + mob.location[1] * self.max)
        for mob in result:
            yield mob.location, mob


    def mobAtLocation(self, point):
        """Searches for mob at point, or None if not found"""
        for mob in self.mobs:
            if mob.location[0] == point[0] and mob.location[1] == point[1]:
                return mob
        return None

    def adjacentEnemyMobs(self, mob):
        """Iterates any adjacent enemy mobs from `mob`"""
        for point in self.adjacentOpenLocations(mob.location):
            enemy = self.mobAtLocation(point)
            if enemy and enemy.team != mob.team:
                yield enemy

    def adjacentOpenLocationsWithoutMobs(self, point):
        """Iterates adjacent open locations from point, for pathfinding"""
        for other in self.adjacentOpenLocations(point):
            mob = self.mobAtLocation(other)
            if not mob:
                yield other

    def adjacentOpenLocations(self, point):
        """Iterates adjacent open locations, without considering mobs on the square"""
        for other in self.adjacentLocations(point):
            if other in self.open_areas:
                yield other

    def adjacentLocations(self, point):
        """Iterates locations adjacent to point"""
        yield (point[0], point[1] - 1)
        yield (point[0] - 1, point[1])
        yield (point[0] + 1, point[1])
        yield (point[0], point[1] + 1)

    def removeDeadMobs(self):
        self.mobs = set(mob for mob in self.mobs if mob.hp > 0)


def floodFill(map, targets, results):
    """Flood fills from a set of target locations, into results, which holds distance to closest target location"""
    value = 0
    for target in targets:
        results[target] = 0
    targets = set(targets)

    while targets:
        current = targets.pop()
        nextValue = results[current] + 1

        for adj in map.adjacentOpenLocationsWithoutMobs(current):
            # already has a value
            if adj in results:
                if results[adj] > nextValue:
                    results[adj] = nextValue
                    targets.add(adj)

            else:
                # no value
                results[adj] = nextValue
                targets.add(adj)


def parseMap(inp, elves_dmg):
    map = Map()
    y = 0
    for line in inp.splitlines():
        x = 0
        for c in line:
            if c == '.' or c == 'G' or c == 'E':
                map.open_areas.add((x, y))
            if c == 'G':
                map.mobs.add(Mob(TEAM_GOBLIN, (x, y), BASE_ATTACK))
            if c == 'E':
                map.mobs.add(Mob(TEAM_ELVES, (x, y), elves_dmg))
            x += 1
        y += 1
        map.max = max(map.max, x, y)
    return map


def shouldMove(map, mob):
    """Mob should not move if there is an enemy that it can attack"""
    return not list(map.adjacentEnemyMobs(mob)):

def decideMove(map, mob):
    # work out where this mob can possibly move to
    possibleMoves = list(map.adjacentOpenLocations(mob.location))
    if not possibleMoves:
        return mob.location


    enemyLocations = [enemy.location for enemy in map.enemyMobs(mob)]
    floodFillResults = defaultdict(lambda: 9999)
    floodFill(map, enemyLocations, floodFillResults)

    # Filter out moves that do not bring us closer to an enemy
    possibleMoves = [x for x in possibleMoves if x in floodFillResults]
    if not possibleMoves:
        return mob.location

    # sort moves by closest to target, then reading order
    moveSorter = lambda location: (floodFillResults[location], location[0] + location[1] * map.max)
    moves = list(sorted(possibleMoves, key=moveSorter))
    return moves[0]

def decideAttack(map, mob):
    def attackSortKey(mob):
        # lowest HP first
        # location reading order otherwise
        return (mob.hp, mob.location[0] + mob.location[1] * map.max)

    attackable = list(sorted(map.adjacentEnemyMobs(mob), key=attackSortKey))
    if attackable:
        return attackable[0]



def runTurn(map):
    """
    Runs a single turn, returns 0 if the turn was interrupted by game ending, or 1 otherwise
    """
    for point, mob in map.mobsByLocation():
        if mob.hp > 0:
            if len(map.countTeams()) != 2:
                return 0

            if shouldMove(map, mob):
                mob.location = decideMove(map, mob)

            attack = decideAttack(map, mob)
            if attack:
                attack.hp -= mob.dmg

        map.removeDeadMobs()
    return 1

def calculatePartOne(inp, dmg=BASE_ATTACK):
    map = parseMap(inp, dmg)

    turn = 0
    while len(map.countTeams()) == 2:
        turn += runTurn(map)

    return turn * map.hitpointSum()


def checkCombatHasNoLosses(inp, dmg):
    """
    Returns true if combat on given map with dmg has no elves losses
    """
    map = parseMap(inp, dmg)
    startingTeams = map.countTeams()

    while True:
        runTurn(map)
        currentTeams = map.countTeams()
        if currentTeams[TEAM_ELVES] < startingTeams[TEAM_ELVES]:
            return False
        if currentTeams[TEAM_GOBLIN] == 0:
            return True


def calculatePartTwo(inp, start = 4):
    """
    Returns min damage required for no elves losses on a given map
    """
    for dmg in range(start, 200):
        if checkCombatHasNoLosses(inp, dmg):
            return dmg


def calculatePartTwoScore(inp, start = 4):
    """
    Returns overall score for combat with min damage for no elves losses
    """
    dmg = calculatePartTwo(inp, start)
    return calculatePartOne(inp, dmg)



inp = """#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######"""
assert(calculatePartOne(inp) == 27730)

inp = """#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######"""
assert(calculatePartOne(inp) == 36334)

inp = """#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######"""
assert(calculatePartOne(inp) == 39514)

inp = """#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######"""
assert(calculatePartOne(inp) == 27755)

inp = """#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######"""
assert(calculatePartOne(inp) == 28944)

inp = """#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########"""
assert(calculatePartOne(inp) == 18740)

inp = """#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######"""
assert(calculatePartTwo(inp) == 15)
assert(calculatePartTwoScore(inp) == 4988)

inp = """#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######"""
assert(calculatePartTwo(inp) == 4)
assert(calculatePartTwoScore(inp) == 31284)

inp = """#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######"""
assert(calculatePartTwo(inp) == 15)
assert(calculatePartTwoScore(inp) == 3478)

inp = """#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######"""
assert(calculatePartTwo(inp) == 12)
assert(calculatePartTwoScore(inp) == 6474)

inp = """#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########"""
assert(calculatePartTwo(inp) == 34)
assert(calculatePartTwoScore(inp) == 1140)


inp = """################################
##########################..####
##########################...###
####################G..#......##
##############.#####G....G....##
##############...#####..##..#.##
################..##...#########
##############....#....#########
#########..###G........E######.#
#########........#..GG..####...#
#########......................#
#########..........G..G........#
########...G..#####............#
#######......#######........####
#####.G.....#########E.......###
######......#########........###
#####.......#########....E######
#####.G...G.#########.....######
######..G...#########.....######
#####...G....#######.......#####
###....G......#####.......######
#.#G.....E......E.........#..###
#............G..G.G.#.#...E....#
####.....................#####.#
########...........EE.##.#######
########..............##########
#########.....G.....E.##########
#########............###########
##########..........############
##########.......E.....#########
##############..##.#..##########
################################"""

print(calculatePartTwoScore(inp, 32))