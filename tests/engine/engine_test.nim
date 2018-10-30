import unittest
import test_data
import ../../src/engine/engine

template checkHP(state: State, pokemon: UUID, hp: int) =
  check(state.getPokemonState(pokemon).currentHP == hp)

suite "Sanity":

  test "engine":
    var gameState = newGame(sanityTeam, sanityTeam)
    let snorlaxH = gameState.getPokemon(tskHome, 0)
    let snorlaxA = gameState.getPokemon(tskAway, 0)
    var action = @[gameState.getMoveAction(snorlaxH, "Return")]
    var nextState = gameState.turn(action)

    checkHP(gameState, snorlaxH, 244)
    check(gameState.getPokemonState(snorlaxA).currentHP == 244)
    check(nextState.getPokemonState(snorlaxH).currentHP == 244)
    check(nextState.getPokemonState(snorlaxA).currentHP == 141)

suite "Weather":

  test "Should end in 5 turns":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(blazeH, "Sunny Day")]
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
      state.getMoveAction(blaze, "Sunny Day"),
      state.getMoveAction(ludi, "Rain Dance")
    ]
    state = turn(state, action)
    check(state.field.weather == fwkRain)

  test "Cannot reset same weather":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(blazeH, "Sunny Day")]
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
    let blaze = state.getPokemon(tskAway, 0)
    check(state.field.weather == fwkHarshSun)
    var action = @[state.getMoveAction(blaze, "Sunny Day")]
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
    let ky = state.getPokemon(tskAway, 0)
    let ludi = state.getPokemon(tskAway, 1)
    check(state.field.weather == fwkHeavyRain)
    var action = @[state.getSwitchAction(ky, ludi)]
    state = turn(state, action)
    check(state.field.weather == fwkNone)

  test "Sun - Boost Fire moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.getMoveAction(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 186)

  test "Sun - Weaken Water moves":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(blazeH, "Sunny Day")]
    state = turn(state, action)
    action = @[state.getMoveAction(blazeH, "Water Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 233)

  test "Rain - Boost Water moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    let ludiA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.getMoveAction(ludiH, "Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 257)

  test "Rain - Weaken Sun moves":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    let ludiA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(ludiH, "Rain Dance")]
    state = turn(state, action)
    action = @[state.getMoveAction(ludiH, "Fire Punch")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 272)

  test "Sand - Damage relevant types":
    var state = newGame(sandstorm1, sandstorm1)
    let dun = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(dun, "Sandstorm")]
    state = turn(state, action)
    check(state.getPokemonState(dun).currentHP == 320)

  test "Sand - Boost Rock types SpD":
    var state = newGame(sandstorm2, sandstorm2)
    let ttarH = state.getPokemon(tskHome, 0)
    let ttarA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(ttarH, "Sandstorm")]
    state = turn(state, action)
    action = @[state.getMoveAction(ttarH, "Dark Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(ttarA).currentHP == 311)

  test "Hail - Damage relevant types":
    var state = newGame(hail1, hail2)
    let abom = state.getPokemon(tskHome, 0)
    let ky = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(abom, "Hail")]
    state = turn(state, action)
    check(state.getPokemonState(abom).currentHP == 321)
    check(state.getPokemonState(ky).currentHP == 320)

  test "Harsh Sun - nullify Water moves":
    var state = newGame(desolateLand, rainDance)
    let groudon = state.getPokemon(tskHome, 0)
    let ludi = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(ludi, "Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(groudon).currentHP == 341)

  test "Heavy Rain - nullify Fire moves":
    var state = newGame(primordialSea, sunnyDay)
    let ky = state.getPokemon(tskHome, 0)
    let blaze = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(blaze, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(ky).currentHP == 341)

  test "Strong Winds - remove Flying weaknesses":
    var state = newGame(deltaStream, utility)
    let ray = state.getPokemon(tskHome, 0)
    let smeargle = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(smeargle, "Stone Edge")]
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
    let mew = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(mew, "Psychic Terrain")]
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
    let fini = state.getPokemon(tskHome, 0)
    let ray = state.getPokemon(tskAway, 0)
    let action = @[state.getMoveAction(fini, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(ray).currentHP == 222)

  test "Psychic - Boost Psychic moves":
    var state = newGame(psychicSurge, technician)
    let lele = state.getPokemon(tskHome, 0)
    let scizor = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(lele, "Psychic")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 161)

  test "Psychic - Block Priority moves":
    var state = newGame(psychicSurge, technician)
    let lele = state.getPokemon(tskHome, 0)
    let scizor = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(scizor, "Bullet Punch")]
    state = turn(state, action)
    check(state.getPokemonState(lele).currentHP == 281)

  test "Electric - Boost Electric moves":
    var state = newGame(electricSurge, technician)
    let koko = state.getPokemon(tskHome, 0)
    let scizor = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(koko, "Volt Switch")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 139)

  test "Misty - Weaken Dragon moves":
    var state = newGame(mistySurge, adaptability)
    let fini = state.getPokemon(tskHome, 0)
    let drag = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(fini, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(drag).currentHP == 218)

  test "Grassy - Boost Grass moves":
    var state = newGame(grassySurge, technician)
    let bulu = state.getPokemon(tskHome, 0)
    let scizor = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(bulu, "Giga Drain")]
    state = turn(state, action)
    check(state.getPokemonState(scizor).currentHP == 246)
  
  test "Grassy - Weaken EQ / Bulldoze":
    var state = newGame(grassySurge, earthquake)
    let bulu = state.getPokemon(tskHome, 0)
    let chomp = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(chomp, "Earthquake")]
    state = turn(state, action)
    check(state.getPokemonState(bulu).currentHP == 249)
    action = @[state.getMoveAction(chomp, "Bulldoze")]
    state = turn(state, action)
    check(state.getPokemonState(bulu).currentHP == 230)

suite "Auras":

  test "Should end on switch out":
    var state = newGame(fairyAura & technician, darkAura)
    let xerneas = state.getPokemon(tskHome, 0)
    let scizor = state.getPokemon(tskHome, 1)
    let yveltal = state.getPokemon(tskAway, 0)
    var actions = @[
      state.getSwitchAction(xerneas, scizor),
      state.getMoveAction(yveltal, "Dazzling Gleam")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(scizor).currentHP == 233)

  test "Should start on switch in":
    var state = newGame(technician & fairyAura, darkAura)
    let scizor = state.getPokemon(tskHome, 0)
    let xerneas = state.getPokemon(tskHome, 1)
    let yveltal = state.getPokemon(tskAway, 0)
    var actions = @[
      state.getSwitchAction(scizor, xerneas),
      state.getMoveAction(yveltal, "Dazzling Gleam")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(xerneas).currentHP == 286)

suite "Moves":

  test "Swords Dance":
    var state = newGame(swordsDance, swordsDance)
    let smeargleH = state.getPokemon(tskHome, 0)
    let smeargleA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(smeargleH, "Swords Dance")]
    state = turn(state, action)
    action = @[state.getMoveAction(smeargleH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smeargleA).currentHP == 133)

  test "Sunny Day":
    var state = newGame(sunnyDay, sunnyDay)
    let blazeH = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(blazeH, "Sunny Day")]
    state = turn(state, action)
    check(state.field.weather == fwkSun)

  test "Rain Dance":
    var state = newGame(rainDance, rainDance)
    let ludiH = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(ludiH, "Rain Dance")]
    state = turn(state, action)
    check(state.field.weather == fwkRain)

  test "Sandstorm":
    var state = newGame(sandstorm1, sandstorm1)
    let dun = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(dun, "Sandstorm")]
    state = turn(state, action)
    check(state.field.weather == fwkSand)

  test "Hail":
    var state = newGame(hail1, hail1)
    let abom = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(abom, "Hail")]
    state = turn(state, action)
    check(state.field.weather == fwkHail)

  test "Psychic Terrain":
    var state = newGame(psychicTerrain, utility)
    let mew = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(mew, "Psychic Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkPsychic)

  test "Electric Terrain":
    var state = newGame(electricTerrain, utility)
    let raikou = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(raikou, "Electric Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkElectric)

  test "Misty Terrain":
    var state = newGame(mistyTerrain, utility)
    let mew = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(mew, "Misty Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkFairy)

  test "Grassy Terrain":
    var state = newGame(grassyTerrain, utility)
    let celebi = state.getPokemon(tskHome, 0)
    var action = @[state.getMoveAction(celebi, "Grassy Terrain")]
    state = turn(state, action)
    check(state.field.terrain == ftkGrass)

  test "Bullet Punch":
    var state = newGame(technician, frail)
    let scizor = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var action = @[
      state.getMoveAction(scizor, "Bullet Punch"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, action)
    check(state.getPokemonState(lando).currentHP == 0)
    check(state.getPokemonState(scizor).currentHP == 281)

suite "Abilities":

  test "Adaptability":
    var state = newGame(adaptability, adaptability)
    let dragH = state.getPokemon(tskHome, 0)
    let dragA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(dragH, "Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(dragA).currentHP == 50)

  test "Intimidate":
    var state = newGame(intimidate, intimidate)
    let smearH = state.getPokemon(tskHome, 0)
    let smearA = state.getPokemon(tskAway, 0)
    let spindA = state.getPokemon(tskAway, 1)
    var action = @[state.getMoveAction(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(smearA).currentHP == 212)
    
    action = @[state.getSwitchAction(smearA, spindA), state.getMoveAction(smearH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 240)

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
    let venu = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(venu, "Sunny Day")]
    state = turn(state, actions)
    actions = @[
      state.getMoveAction(venu, "Giga Drain"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(venu).currentHP == 301)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Swift Swim":
    var state = newGame(swiftswim, frail)
    let ludi = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(ludi, "Rain Dance")]
    state = turn(state, actions)
    actions = @[
      state.getMoveAction(ludi, "Scald"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(ludi).currentHP == 301)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Sand Rush":
    var state = newGame(sandrush, frail)
    let drill = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(drill, "Sandstorm")]
    state = turn(state, actions)
    actions = @[
      state.getMoveAction(drill, "Iron Head"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(drill).currentHP == 361)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Slush Rush":
    var state = newGame(slushrush, frail)
    let slash = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(slash, "Hail")]
    state = turn(state, actions)
    actions = @[
      state.getMoveAction(slash, "Icicle Crash"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(slash).currentHP == 291)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Surge Surfer":
    var state = newGame(surgesurfer, frail)
    let pika = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(pika, "Electric Terrain")]
    state = turn(state, actions)
    actions = @[
      state.getMoveAction(pika, "Surf"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(pika).currentHP == 211)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Fairy Aura":
    var state = newGame(fairyAura, darkAura)
    let xerneas = state.getPokemon(tskHome, 0)
    let yveltal = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(xerneas, "Dazzling Gleam")]
    state = turn(state, actions)
    check(state.getPokemonState(yveltal).currentHP == 73)

  test "Dark Aura":
    var state = newGame(fairyAura, darkAura)
    let xerneas = state.getPokemon(tskHome, 0)
    let yveltal = state.getPokemon(tskAway, 0)
    var actions = @[state.getMoveAction(yveltal, "Dark Pulse")]
    state = turn(state, actions)
    check(state.getPokemonState(xerneas).currentHP == 313)

suite "Items":

  test "Choice Band":
    var state = newGame(choiceBand, choiceBand)
    let spindH = state.getPokemon(tskHome, 0)
    let spindA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(spindH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 137)

  test "Choice Specs":
    var state = newGame(choiceSpecs, choiceSpecs)
    let spindH = state.getPokemon(tskHome, 0)
    let spindA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(spindH, "Hyper Voice")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 102)

  test "Choice Scarf":
    var state = newGame(choiceScarf, frail)
    let ttar = state.getPokemon(tskHome, 0)
    let lando = state.getPokemon(tskAway, 0)
    var actions = @[
      state.getMoveAction(ttar, "Crunch"),
      state.getMoveAction(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(ttar).currentHP == 341)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Life Orb":
    var state = newGame(lifeOrb, lifeOrb)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 202)
    check(state.getPokemonState(blazeH).currentHP == 271)

  test "Pinch Berries - Should be consumed":
    var state = newGame(pinchBerryAttacker, magoBerry)
    let heatran = state.getPokemon(tskHome, 0)
    let venu = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(heatran, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 186)
    action = @[state.getMoveAction(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 8)

  test "Mago Berry":
    var state = newGame(pinchBerryAttacker, magoBerry)
    let heatran = state.getPokemon(tskHome, 0)
    let venu = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(heatran, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 186)

  test "Resist Berries - Should be consumed":
    var state = newGame(occaBerryAttacker, occaBerry)
    let heatran = state.getPokemon(tskHome, 0)
    let venu = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 212)
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 34)

  test "Occa Berry":
    var state = newGame(occaBerryAttacker, occaBerry)
    let heatran = state.getPokemon(tskHome, 0)
    let venu = state.getPokemon(tskAway, 0)
    var action = @[state.getMoveAction(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 212)

  test "Z moves - One Z move per game":
    var state = newGame(firiumZ, firiumZ)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[
      state.getMoveAction(blazeH, "Z-Fire Blast")
    ]
    state = turn(state, action)
    expect CatchableError:
      discard state.getMoveAction(blazeH, "Z-Fire Blast")
    action = @[
      state.getMoveAction(blazeA, "Z-Fire Blast")
    ]
    state = turn(state, action)

  test "Firium Z":
    var state = newGame(firiumZ, firiumZ)
    let blazeH = state.getPokemon(tskHome, 0)
    let blazeA = state.getPokemon(tskAway, 0)
    var action = @[
      state.getMoveAction(blazeH, "Z-Fire Blast")
    ]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 144)
