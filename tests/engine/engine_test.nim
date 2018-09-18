import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = sanityState()
    var activePokemon = gameState.homeActivePokemon()
    var possibleActions = gameState.possibleActions(activePokemon)
    var actions = @[possibleActions[0]]
    var nextState = gameState.turn(actions)

    check(gameState.homeTeam[0].currentHP == 244)
    check(gameState.awayTeam[0].currentHP == 244)
    check(nextState.homeTeam[0].currentHP == 244)
    check(nextState.awayTeam[0].currentHP == 141)
