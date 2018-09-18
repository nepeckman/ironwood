import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = sanityState()
    var attacker = gameState.homeTeam.members[0]
    var defender = gameState.awayTeam.members[0]
    var actions: ActionSet = initSet[Action]()
    actions.incl(newMoveAction(attacker.uuid, attacker.moves[0], {atkEnemyOne}))
    gameState = gameState.turn(actions)
    check(attacker.currentHP == 244)
    check(defender.currentHP == 244)
    check(gameState.homeTeam.members[0].currentHP == 244)
    check(gameState.awayTeam.members[0].currentHP == 141)
