import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = sanityState()
    var attacker = gameState.homeTeam[0]
    var defender = gameState.awayTeam[0]
    discard gameState.awayActivePokemon()
    var possibleActions = gameState.possibleActions(attacker)
    var actions: ActionSet = initSet[Action]()
    actions.incl(possibleActions[0])
    gameState = gameState.turn(actions)
    check(attacker.currentHP == 244)
    check(defender.currentHP == 244)
    check(gameState.homeTeam[0].currentHP == 244)
    check(gameState.awayTeam[0].currentHP == 141)
