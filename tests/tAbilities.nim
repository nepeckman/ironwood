import unittest
import data/abilitySets
import utils

suite "Abilities":

  test "Adaptability":
    var state = newGame(adaptability, adaptability)
    let dragH = state.getPokemonID(tskHome, 0)
    let dragA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(dragH, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(dragA).currentHP == 50)

  test "Aerilate":
    var (state, salamenceH, salamenceA) = gameSetup(aerilate, aerilate)
    var action = @[state.attack(salamenceH, "Return")]
    state = turn(state, action)
    state.checkHP(salamenceA, 174)

  test "Analytic":
    var (state, porygon, mence) = gameSetup(analytic, aerilate)
    var actions = @[state.attack(mence, "Return"), state.attack(porygon, "Discharge")]
    state = turn(state, actions)
    state.checkHP(mence, 238)
    actions = @[state.attack(porygon, "Discharge")]
    state = turn(state, actions)
    state.checkHP(mence, 166)

  test "Beast Boost":
    var state = newGame(beastBoost, frail & lifeOrb)
    let kartana = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    let blaze = state.getPokemonID(tskAway, 1)
    var actions = @[state.attack(kartana, "Leaf Blade")]
    state = turn(state, actions)
    actions = @[state.switch(lando, blaze)]
    state = turn(state, actions)
    actions = @[state.attack(kartana, "Leaf Blade")]
    state = turn(state, actions)
    state.checkHP(blaze, 123)

  test "Intimidate":
    var state = newGame(intimidate, intimidate)
    let smearH = state.getPokemonID(tskHome, 0)
    let smearA = state.getPokemonID(tskAway, 0)
    let spindA = state.getPokemonID(tskAway, 1)
    var action = @[state.attack(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smearA).currentHP == 212)
    
    action = @[state.switch(smearA, spindA), state.attack(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 240)

  test "Air Lock":
    var state = newGame(airLock & rainDance, drought & drizzle)
    let rayquaza = state.getPokemonID(tskHome, 0)
    let ludi = state.getPokemonID(tskHome, 1)
    let torkoal = state.getPokemonID(tskAway, 0)
    let politoed = state.getPokemonID(tskAway, 1)
    
    var action = @[state.attack(rayquaza, "Flamethrower")]
    state = turn(state, action)
    state.checkHP(torkoal, 214)

    action = @[state.switch(rayquaza, ludi)]
    state = turn(state, action)
    action = @[state.attack(ludi, "Hydro Pump")]
    state = turn(state, action)
    state.checkHP(torkoal, 58)

  test "Drought":
    var state = newGame(drought, drought)
    check(state.field.weather == fwkSun)

  test "Drizzle":
    var state = newGame(drizzle, drizzle)
    check(state.field.weather == fwkRain)

  test "Sand Stream":
    var state = newGame(sandstream, sandstream)
    check(state.field.weather == fwkSand)

  test "Snow Warning":
    var state = newGame(snowWarning, snowWarning)
    check(state.field.weather == fwkHail)

  test "Desolate Land":
    var state = newGame(desolateLand, utility)
    check(state.field.weather == fwkHarshSun)

  test "Primordial Sea":
    var state = newGame(primordialSea, utility)
    check(state.field.weather == fwkHeavyRain)

  test "Delta Stream":
    var state = newGame(deltaStream, utility)
    check(state.field.weather == fwkStrongWinds)

  test "Psychic Surge":
    var state = newGame(psychicSurge, utility)
    check(state.field.terrain == ftkPsychic)
  
  test "Electric Surge":
    var state = newGame(electricSurge, utility)
    check(state.field.terrain == ftkElectric)

  test "Misty Surge":
    var state = newGame(mistySurge, utility)
    check(state.field.terrain == ftkFairy)

  test "Grassy Surge":
    var state = newGame(grassySurge, utility)
    check(state.field.terrain == ftkGrass)

  test "Chlorophyll":
    var state = newGame(chlorophyll, frail)
    let venu = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(venu, "Sunny Day")]
    state = turn(state, actions)
    actions = @[
      state.attack(venu, "Giga Drain"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(venu).currentHP == 301)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Swift Swim":
    var state = newGame(swiftswim, frail)
    let ludi = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(ludi, "Rain Dance")]
    state = turn(state, actions)
    actions = @[
      state.attack(ludi, "Scald"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(ludi).currentHP == 301)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Sand Rush":
    var state = newGame(sandrush, frail)
    let drill = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(drill, "Sandstorm")]
    state = turn(state, actions)
    actions = @[
      state.attack(drill, "Iron Head"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(drill).currentHP == 361)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Slush Rush":
    var state = newGame(slushrush, frail)
    let slash = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(slash, "Hail")]
    state = turn(state, actions)
    actions = @[
      state.attack(slash, "Icicle Crash"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(slash).currentHP == 291)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Surge Surfer":
    var state = newGame(surgesurfer, frail)
    let pika = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(pika, "Electric Terrain")]
    state = turn(state, actions)
    actions = @[
      state.attack(pika, "Surf"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(pika).currentHP == 211)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Fairy Aura":
    var state = newGame(fairyAura, darkAura)
    let xerneas = state.getPokemonID(tskHome, 0)
    let yveltal = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(xerneas, "Dazzling Gleam")]
    state = turn(state, actions)
    check(state.getPokemonState(yveltal).currentHP == 73)

  test "Dark Aura":
    var state = newGame(fairyAura, darkAura)
    let xerneas = state.getPokemonID(tskHome, 0)
    let yveltal = state.getPokemonID(tskAway, 0)
    var actions = @[state.attack(yveltal, "Dark Pulse")]
    state = turn(state, actions)
    check(state.getPokemonState(xerneas).currentHP == 313)

  test "Aura Break":
    var (state, z, y) = gameSetup(auraBreak, darkAura)
    var actions = @[state.attack(y, "Dark Pulse")]
    state = turn(state, actions)
    state.checkHP(z, 264)
