import unittest, utils
import data/mechanicSets

suite "Weather":

  test "Should end in 5 turns":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(blazeH, "Sunny Day")]
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
    let blaze = state.getPokemonID(tskHome, 0)
    let ludi = state.getPokemonID(tskAway, 0)
    var action = @[
      state.attack(blaze, "Sunny Day"),
      state.attack(ludi, "Rain Dance")
    ]
    state = turn(state, action)
    check(state.field.weather == fwkRain)

  test "Cannot reset same weather":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(blazeH, "Sunny Day")]
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

  test "Strong weather prevents normal weather":
    var state = newGame(desolateLand, sunnyDay)
    let blaze = state.getPokemonID(tskAway, 0)
    check(state.field.weather == fwkHarshSun)
    var action = @[state.attack(blaze, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkHarshSun)
    
    state = newGame(desolateLand, drought)
    check(state.field.weather == fwkHarshSun)

  test "Strong weather never ends":
    var state = newGame(deltaStream, deltaStream)
    check(state.field.weather == fwkStrongWinds)
    state = turn(state, @[])
    check(state.field.weather == fwkStrongWinds)
    state = turn(state, @[])
    check(state.field.weather == fwkStrongWinds)
    state = turn(state, @[])
    check(state.field.weather == fwkStrongWinds)
    state = turn(state, @[])
    check(state.field.weather == fwkStrongWinds)
    state = turn(state, @[])
    check(state.field.weather == fwkStrongWinds)

  test "Strong weather ends on switch out":
    var state = newGame(deltaStream, primordialSea & rainDance)
    let ky = state.getPokemonID(tskAway, 0)
    let ludi = state.getPokemonID(tskAway, 1)
    check(state.field.weather == fwkHeavyRain)
    var action = @[state.switch(ky, ludi)]
    state = turn(state, action)
    check(state.field.weather == fwkNone)

  test "Sun - Boost Fire moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemonID(tskHome, 0)
    let blazeA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.attack(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 186)

  test "Sun - Weaken Water moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemonID(tskHome, 0)
    let blazeA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.attack(blazeH, "Water Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 233)

  test "Rain - Boost Water moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemonID(tskHome, 0)
    let ludiA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.attack(ludiH, "Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 257)

  test "Rain - Weaken Sun moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemonID(tskHome, 0)
    let ludiA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.attack(ludiH, "Fire Punch")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 272)

  test "Sand - Damage relevant types":
    var state = newGame(sandstorm1, sandstorm1)
    let dun = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(dun, "Sandstorm")]
    state = turn(state, action)
    check(state.getPokemonState(dun).currentHP == 320)

  test "Sand - Boost Rock types SpD":
    var state = newGame(sandstorm2, sandstorm2)
    let ttarH = state.getPokemonID(tskHome, 0)
    let ttarA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(ttarH, "Sandstorm")]
    state = turn(state, action)
    action = @[state.attack(ttarH, "Dark Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(ttarA).currentHP == 311)

  test "Hail - Damage relevant types":
    var state = newGame(hail1, hail2)
    let abom = state.getPokemonID(tskHome, 0)
    let ky = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(abom, "Hail")]
    state = turn(state, action)
    check(state.getPokemonState(abom).currentHP == 321)
    check(state.getPokemonState(ky).currentHP == 320)

  test "Harsh Sun - nullify Water moves":
    var state = newGame(desolateLand, rainDance)
    let groudon = state.getPokemonID(tskHome, 0)
    let ludi = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(ludi, "Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(groudon).currentHP == 341)

  test "Heavy Rain - nullify Fire moves":
    var state = newGame(primordialSea, sunnyDay)
    let ky = state.getPokemonID(tskHome, 0)
    let blaze = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(blaze, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(ky).currentHP == 341)

  test "Strong Winds - remove Flying weaknesses":
    var state = newGame(deltaStream, utility)
    let ray = state.getPokemonID(tskHome, 0)
    let smeargle = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(smeargle, "Stone Edge")]
    state = turn(state, action)
    check(state.getPokemonState(ray).currentHP == 325)

suite "Terrain":

  test "Should end in 5 turns":
    var state = newGame(psychicSurge, utility)
    check(state.field.terrain == ftkPsychic)
    state = turn(state, @[])
    check(state.field.terrain == ftkPsychic)
    state = turn(state, @[])
    check(state.field.terrain == ftkPsychic)
    state = turn(state, @[])
    check(state.field.terrain == ftkPsychic)
    state = turn(state, @[])
    check(state.field.terrain == ftkPsychic)
    state = turn(state, @[])
    check(state.field.terrain == ftkNone)

  test "Cannot reset same terrain":
    var state = newGame(psychicTerrain, utility)
    let mew = state.getPokemonID(tskHome, 0)
    var action = @[state.attack(mew, "Psychic Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)
    state = turn(state, action)
    check(state.field.terrain == ftkNone)

  test "Levitating Pokemon do not receive benefits":
    var state = newGame(mistySurge, deltaStream)
    let fini = state.getPokemonID(tskHome, 0)
    let ray = state.getPokemonID(tskAway, 0)
    let action = @[state.attack(fini, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(ray).currentHP == 222)

  test "Psychic - Boost Psychic moves":
    var state = newGame(psychicSurge, technician)
    let lele = state.getPokemonID(tskHome, 0)
    let scizor = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(lele, "Psychic")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 161)

  test "Psychic - Block Priority moves":
    var state = newGame(psychicSurge, technician)
    let lele = state.getPokemonID(tskHome, 0)
    let scizor = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(scizor, "Bullet Punch")]
    state = turn(state, action)
    check(state.getPokemonState(lele).currentHP == 281)

  test "Electric - Boost Electric moves":
    var state = newGame(electricSurge, technician)
    let koko = state.getPokemonID(tskHome, 0)
    let scizor = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(koko, "Volt Switch")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 139)

  test "Misty - Weaken Dragon moves":
    var state = newGame(mistySurge, adaptability)
    let fini = state.getPokemonID(tskHome, 0)
    let drag = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(fini, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(drag).currentHP == 218)

  test "Grassy - Boost Grass moves":
    var state = newGame(grassySurge, technician)
    let bulu = state.getPokemonID(tskHome, 0)
    let scizor = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(bulu, "Giga Drain")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 246)
  
  test "Grassy - Weaken EQ / Bulldoze":
    var state = newGame(grassySurge, earthquake)
    let bulu = state.getPokemonID(tskHome, 0)
    let chomp = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(chomp, "Earthquake")]
    state = turn(state, action)
    check(state.getPokemonState(bulu).currentHP == 249)
    action = @[state.attack(chomp, "Bulldoze")]
    state = turn(state, action)
    check(state.getPokemonState(bulu).currentHP == 230)

suite "Auras":

  test "Should end on switch out":
    var state = newGame(fairyAura & technician, darkAura)
    let xerneas = state.getPokemonID(tskHome, 0)
    let scizor = state.getPokemonID(tskHome, 1)
    let yveltal = state.getPokemonID(tskAway, 0)
    var actions = @[
      state.switch(xerneas, scizor),
      state.attack(yveltal, "Dazzling Gleam")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(scizor).currentHP == 233)

  test "Should start on switch in":
    var state = newGame(technician & fairyAura, darkAura)
    let scizor = state.getPokemonID(tskHome, 0)
    let xerneas = state.getPokemonID(tskHome, 1)
    let yveltal = state.getPokemonID(tskAway, 0)
    var actions = @[
      state.switch(scizor, xerneas),
      state.attack(yveltal, "Dazzling Gleam")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(xerneas).currentHP == 286)
