import unittest, sets
import engine_test_data
import ../../src/engine/[damage, pokemon, pokemove, team, state, field, poketype, action, engine]

suite "Sanity":

  test "damage":
    var gameState = sanityState()
    let attacker = gameState.homeTeam.activePokemon
    let defender = gameState.awayTeam.activePokemon
    let damage = getDamageSpread(attacker, defender, attacker.moves[0], gameState)
    check(damage == [94, 96, 97, 99, 99, 100, 102, 103, 103, 105, 106, 108, 108, 109, 111, 112])

  test "engine":
    var gameState = sanityState()
    var attacker = gameState.homeTeam.activePokemon
    var defender = gameState.awayTeam.activePokemon
    var actions: HashSet[Action] = initSet[Action]()
    actions.incl(newMoveAction(attacker.uuid, attacker.moves[0], defender.uuid))
    gameState = gameState.turn(actions)
    check(attacker.currentHP == 244)
    check(defender.currentHP == 244)
    check(gameState.homeTeam.activePokemon.currentHP == 244)
    check(gameState.awayTeam.activePokemon.currentHP == 141)
