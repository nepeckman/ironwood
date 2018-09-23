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

  test "Sunny Day":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)

    action = @[state.getActionByMove(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 186)
    
    state = turn(state, @[])
    state = turn(state, @[])
    state = turn(state, @[])
    check(state.field.weather == fwkNone)

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

suite "Items":

  test "Choice Band":
    var state = newGame(choiceBand, choiceBand)
    let spindH = state.getPokemon(tskHome, 0)
    let spindA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(spindH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 137)

  test "Choice Specs":
    var state = newGame(choiceSpecs, choiceSpecs)
    let spindH = state.getPokemon(tskHome, 0)
    let spindA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(spindH, "Hyper Voice")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 102)
