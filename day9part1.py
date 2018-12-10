from collections import defaultdict

class MarbleGame:
    def __init__(self):
        self.marbles = [0]
        self.currentLocation = 1
        self.currentPlayer = 0
        self.marbleScore = 1
        self.numPlayers = 0
        self.playerScores = defaultdict(int)


def playRound(game):
    if game.marbleScore % 23 == 0:
        game.playerScores[game.currentPlayer] += game.marbleScore

        removecurrentLocation = (game.currentLocation - 7)
        if removecurrentLocation < 0:
            removecurrentLocation += len(game.marbles)

        removedScore = game.marbles.pop(removecurrentLocation)

        game.playerScores[game.currentPlayer] += removedScore
        game.currentLocation = removecurrentLocation

    else:
        left = (game.currentLocation + 1) % len(game.marbles)
        right = (game.currentLocation + 2)  % len(game.marbles)

        if left >= right:
            game.marbles.insert(left + 1, game.marbleScore)
            game.currentLocation = left + 1
        else:
            game.marbles.insert(right, game.marbleScore)
            game.currentLocation = right

    game.currentPlayer = (game.currentPlayer + 1) % game.numPlayers
    game.marbleScore += 1


def playGame(players, lastMarbleScore):
    print("New Game")
    game = MarbleGame()
    game.numPlayers = players

    for i in range(lastMarbleScore):
        if i%1000 == 0:
            print("ROUND: ", i+1)
        playRound(game)

    return game



def maxScores(game):
    return max(game.playerScores.values())

def main():
    assert(maxScores(playGame(9, 25)) == 32)
    assert(maxScores(playGame(10, 1618)) == 8317)
    assert(maxScores(playGame(13, 7999)) == 146373)
    assert(maxScores(playGame(17, 1104)) == 2764)
    assert(maxScores(playGame(21, 6111)) == 54718)
    assert(maxScores(playGame(30, 5807)) == 37305)
    print(maxScores(playGame(405, 7095300)))

if __name__ == '__main__':
    main()
