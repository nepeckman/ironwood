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

suite "Weather":

  test "Should end in 5 turns":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)
    state = turn(state, @[])
    check(state.field.weather == fwkSun)
    state = turn(state, @[])
    check(state.field.weather == fwkSun )
    state = turn(state, @[])
    check(state.field.weather == fwkSun)
    state = turn(state, @[])
    check(state.field.weather == fwkNone)

  test "Slower weather wins":
    var state = newGame(sunnyDay, rainDance)
    let blaze = state.getPokemon(tskHome, 0)
    let ludi = state.getPokemon(tskAway, 0)
    var action = @[
      state.getActionByMove(blaze, "Sunny Day"),
      state.getActionByMove(ludi, "Rain Dance")
    ]
    state = turn(state, action)
    check(state.field.weather == fwkRain)

  test "Cannot reset same weather":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)
    state = turn(state, action)
    check(state.field.weather == fwkSun)
    state = turn(state, @[])
    check(state.field.weather == fwkSun )
    state = turn(state, @[])
    check(state.field.weather == fwkSun)
    state = turn(state, @[])
    check(state.field.weather == fwkNone)

  test "Sun - Boost Fire moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.getActionByMove(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 186)

  test "Sun - Weaken Water moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.getActionByMove(blazeH, "Water Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 233)

  test "Rain - Boost Water moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    let ludiA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.getActionByMove(ludiH, "Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 257)

  test "Rain - Weaken Sun moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    let ludiA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.getActionByMove(ludiH, "Fire Punch")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 272)

  test "Sand - Damage relevant types":
    var state = newGame(sandstorm1, sandstorm1)
    let dun = state.getPokemon(tskHome, 0)
    var action = @[state.getActionByMove(dun, "Sandstorm")]
    state = turn(state, action)
    check(state.getPokemonState(dun).currentHP == 320)

  test "Sand - Boost Rock types SpD":
    var state = newGame(sandstorm2, sandstorm2)
    let ttarH = state.getPokemon(tskHome, 0)
    let ttarA = state.getPokemon(tskAway, 0)
    var action = @[state.getActionByMove(ttarH, "Sandstorm")]
    state = turn(state, action)
    action = @[state.getActionByMove(ttarH, "Dark Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(ttarA).currentHP == 311)


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
    var action = @[state.getActionByMove(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)

  test "Rain Dance":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    var action = @[state.getActionByMove(ludiH, "Rain Dance")]
    state = turn(state, action)
    check(state.field.weather == fwkRain)


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
