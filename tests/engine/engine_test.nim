import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = sanityState()
    var attacker = gameState.homeTeam.members[0]
    var defender = gameState.awayTeam.members[0]
    var possibleActions = gameState.possibleActions(attacker)
    var actions: ActionSet = initSet[Action]()
    actions.incl(possibleActions[0])
    gameState = gameState.turn(actions)
    check(attacker.currentHP == 244)
    check(defender.currentHP == 244)
    check(gameState.homeTeam.members[0].currentHP == 244)
    check(gameState.awayTeam.members[0].currentHP == 141)
