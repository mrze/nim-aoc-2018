import sequtils
import tables
import sugar
import math
import lists

type
  MarbleGame = ref object
    marbles: DoublyLinkedRing[int]
    currentLocation: DoublyLinkedNode[int]
    currentPlayer: int
    marbleScore: int
    numPlayers: int
    playerScores: CountTableRef[int]


proc playRound(game: MarbleGame): void =
    if game.marbleScore %% 23 == 0:
        game.playerScores.inc(game.currentPlayer, game.marbleScore)

        for i in countup(1, 7):
            game.currentLocation = game.currentLocation.prev

        var removedScore = game.currentLocation.value
        var removedNode = game.currentLocation
        game.marbles.remove(game.currentLocation)
        game.currentLocation = removedNode.next;

        game.playerScores.inc(game.currentPlayer, removedScore)

    else:
        var insert = newDoublyLinkedNode[int](game.marbleScore)
        var insertAfter = game.currentLocation.next

        insert.next = insertAfter.next
        insert.prev = insertAfter

        insertAfter.next.prev = insert
        insertAfter.next = insert

        game.currentLocation = insert

    game.currentPlayer = (game.currentPlayer + 1) %% game.numPlayers
    game.marbleScore += 1


proc playGame(players: int, lastMarbleScore: int): MarbleGame =
    var game = MarbleGame(marbles: initDoublyLinkedRing[int](),
                          marbleScore: 1,
                          numPlayers: players,
                          playerScores: newCountTable[int]())
    game.marbles.append(0)
    game.currentLocation = game.marbles.head

    for i in countup(0, lastMarbleScore):
        playRound(game)

    return game



proc maxScores(game: MarbleGame): int =
    var (player, score) = game.playerScores.largest()
    return score

assert(maxScores(playGame(9, 25)) == 32)
assert(maxScores(playGame(10, 1618)) == 8317)
assert(maxScores(playGame(13, 7999)) == 146373)
assert(maxScores(playGame(17, 1104)) == 2764)
assert(maxScores(playGame(21, 6111)) == 54718)
assert(maxScores(playGame(30, 5807)) == 37305)
assert(maxScores(playGame(405, 70953)) == 422980)
echo maxScores(playGame(405, 7095300))

