import unittest
import test_data
import ../../src/engine/engine

suite "Sanity":

  test "engine":
    var gameState = newGame(sanityTeam, sanityTeam)
    let snorlaxH = gameState.getPokemon(tskHome, 0)
    let snorlaxA = gameState.getPokemon(tskAway, 0)
    var action = @[gameState.getActionByMove(snorlaxH, "Return")]
    var nextState = gameState.turn(action)

    check(gameState.getPokemonState(snorlaxH).currentHP == 244)
    check(gameState.getPokemonState(snorlaxA).currentHP == 244)
    check(nextState.getPokemonState(snorlaxH).currentHP == 244)
    check(nextState.getPokemonState(snorlaxA).currentHP == 141)

suite "Moves":

  test "Swords Dance":
    var state = newGame(swordsDance, swordsDance)
    let smeargleH = state.getPokemon(tskHome, 0)
    let smeargleA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(smeargleH, "Swords Dance")]
    state = turn(state, action)
    action = @[state.getActionByMove(smeargleH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smeargleA).currentHP == 133)

suite "Abilities":

  test "Adaptability":
    var state = newGame(adaptability, adaptability)
    let dragH = state.getPokemon(tskHome, 0)
    let dragA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(dragH, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(dragA).currentHP == 50)

  test "Intimidate":
    var state = newGame(intimidate, intimidate)
    let smearH = state.getPokemon(tskHome, 0)
    let smearA = state.getPokemon(tskAway, 0)
    let spindA = state.getPokemon(tskAway, 1)
    var action = @[state.getActionByMove(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smearA).currentHP == 212)
    
    action = @[state.getActionBySwitch(smearA, "Spinda"), state.getActionByMove(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 240)
