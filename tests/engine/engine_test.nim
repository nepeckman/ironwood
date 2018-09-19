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

    check(gameState.getPokemonState(tskHome, 0).currentHP == 244)
    check(gameState.getPokemonState(tskAway, 0).currentHP == 244)
    check(nextState.getPokemonState(tskHome, 0).currentHP == 244)
    check(nextState.getPokemonState(tskAway, 0).currentHP == 141)
