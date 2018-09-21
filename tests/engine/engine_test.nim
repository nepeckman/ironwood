import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = newGame(sanityTeam, sanityTeam)
    var action = @[gameState.getActionByMove(tskHome, "Return")]
    var nextState = gameState.turn(action)

    check(gameState.getPokemonState(tskHome, 0).currentHP == 244)
    check(gameState.getPokemonState(tskAway, 0).currentHP == 244)
    check(nextState.getPokemonState(tskHome, 0).currentHP == 244)
    check(nextState.getPokemonState(tskAway, 0).currentHP == 141)

suite "Moves":

  test "Swords Dance":
    var state = newGame(swordsDance, swordsDance)
    var action = @[state.getActionByMove(tskHome, "Swords Dance")]
    state = turn(state, action)
    action = @[state.getActionByMove(tskHome, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(tskAway, 0).currentHP == 133)

suite "Abilities":

  test "Intimidate":
    var state = newGame(intimidate, intimidate)
    var action = @[state.getActionByMove(tskHome, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(tskAway, 0).currentHP == 212)
    
    action = @[state.getActionBySwitch(tskAway, "Spinda"), state.getActionByMove(tskHome, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(tskAway, 0).currentHP == 240)
