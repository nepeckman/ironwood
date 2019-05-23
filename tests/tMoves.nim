import unittest
import data/moveSets
import utils

suite "Moves":

  test "Swords Dance":
    var state = newGame(swordsDance, swordsDance)
    let smeargleH = state.getPokemonID(tskHome, 0)
    let smeargleA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(smeargleH, "Swords Dance")]
    state = turn(state, action)
    action = @[state.attack(smeargleH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smeargleA).currentHP == 133)

  test "Sunny Day":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)

  test "Rain Dance":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(ludiH, "Rain Dance")]
    state = turn(state, action)
    check(state.field.weather == fwkRain)

  test "Sandstorm":
    var state = newGame(sandstorm1, sandstorm1)
    let dun = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(dun, "Sandstorm")]
    state = turn(state, action)
    check(state.field.weather == fwkSand)

  test "Hail":
    var state = newGame(hail1, hail1)
    let abom = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(abom, "Hail")]
    state = turn(state, action)
    check(state.field.weather == fwkHail)

  test "Psychic Terrain":
    var state = newGame(psychicTerrain, utility)
    let mew = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(mew, "Psychic Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)

  test "Electric Terrain":
    var state = newGame(electricTerrain, utility)
    let raikou = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(raikou, "Electric Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkElectric)

  test "Misty Terrain":
    var state = newGame(mistyTerrain, utility)
    let mew = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(mew, "Misty Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkFairy)

  test "Grassy Terrain":
    var state = newGame(grassyTerrain, utility)
    let celebi = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(celebi, "Grassy Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkGrass)

  test "Bullet Punch":
    var state = newGame(technician, frail)
    let scizor = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var action = @[
      state.attack(scizor, "Bullet Punch"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, action)
    check(state.getPokemonState(lando).currentHP == 0)
    check(state.getPokemonState(scizor).currentHP == 281)
