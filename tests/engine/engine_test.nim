import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = sanityState()
    var attacker = gameState.homeTeam.activePokemon
    var defender = gameState.awayTeam.activePokemon
    var actions: ActionSet = initSet[Action]()
    actions.incl(newMoveAction(attacker.uuid, attacker.moves[0], defender.uuid))
    gameState = gameState.turn(actions)
    check(attacker.currentHP == 244)
    check(defender.currentHP == 244)
    check(gameState.homeTeam.activePokemon.currentHP == 244)
    check(gameState.awayTeam.activePokemon.currentHP == 141)
