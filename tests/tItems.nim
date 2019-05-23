import unittest
import data/itemSets
import utils

suite "Items":

  test "Choice Band":
    var state = newGame(choiceBand, choiceBand)
    let spindH = state.getPokemonID(tskHome, 0)
    let spindA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(spindH, "Headbutt")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 137)

  test "Choice Specs":
    var state = newGame(choiceSpecs, choiceSpecs)
    let spindH = state.getPokemonID(tskHome, 0)
    let spindA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(spindH, "Hyper Voice")]
    state = turn(state, action)
    check(state.getPokemonState(spindA).currentHP == 102)

  test "Choice Scarf":
    var state = newGame(choiceScarf, frail)
    let ttar = state.getPokemonID(tskHome, 0)
    let lando = state.getPokemonID(tskAway, 0)
    var actions = @[
      state.attack(ttar, "Crunch"),
      state.attack(lando, "Earthquake")
    ]
    state = turn(state, actions)
    check(state.getPokemonState(ttar).currentHP == 341)
    check(state.getPokemonState(lando).currentHP == 0)

  test "Life Orb":
    var state = newGame(lifeOrb, lifeOrb)
    let blazeH = state.getPokemonID(tskHome, 0)
    let blazeA = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(blazeH, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 202)
    check(state.getPokemonState(blazeH).currentHP == 271)

  test "Pinch Berries - Should be consumed":
    var state = newGame(pinchBerryAttacker, magoBerry)
    let heatran = state.getPokemonID(tskHome, 0)
    let venu = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(heatran, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 186)
    action = @[state.attack(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 8)

  test "Mago Berry":
    var state = newGame(pinchBerryAttacker, magoBerry)
    let heatran = state.getPokemonID(tskHome, 0)
    let venu = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(heatran, "Flamethrower")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 186)

  test "Resist Berries - Should be consumed":
    var state = newGame(occaBerryAttacker, occaBerry)
    let heatran = state.getPokemonID(tskHome, 0)
    let venu = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 212)
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 34)

  test "Occa Berry":
    var state = newGame(occaBerryAttacker, occaBerry)
    let heatran = state.getPokemonID(tskHome, 0)
    let venu = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(heatran, "Hidden Power Fire")]
    state = turn(state, action)
    check(state.getPokemonState(venu).currentHP == 212)

  test "Z moves - One Z move per game":
    var state = newGame(firiumZ, firiumZ)
    let blazeH = state.getPokemonID(tskHome, 0)
    let blazeA = state.getPokemonID(tskAway, 0)
    var action = @[
      state.attack(blazeH, "Z-Fire Blast")
    ]
    state = turn(state, action)
    expect UnpackError:
      discard state.attack(blazeH, "Z-Fire Blast")
    action = @[
      state.attack(blazeA, "Z-Fire Blast")
    ]
    state = turn(state, action)

  test "Custom Z moves - need specific move":
    var state = newGame(aloraichiumZ, noZRaichu)
    let zchu = state.getPokemonID(tskHome, 0)
    let chu = state.getPokemonID(tskAway, 0)
    var action = @[state.attack(zchu, "Stoked Sparksurfer")]
    state = turn(state, action)
    expect UnpackError:
      discard state.attack(chu, "Stoked Sparksurfer")
    expect UnpackError:
      discard state.attack(zchu, "Stoked Sparksurfer")
    check(state.getPokemonState(chu).currentHP == 149)

  test "Firium Z":
    var (state, blazeH, blazeA) = gameSetup(firiumZ, firiumZ)
    var action = @[state.attack(blazeH, "Z-Fire Blast")]
    state = turn(state, action)
    check(state.getPokemonState(blazeA).currentHP == 144)

  test "Waterium Z":
    var (state, ludiH, ludiA) = gameSetup(wateriumZ, wateriumZ)
    var action = @[state.attack(ludiH, "Z-Hydro Pump")]
    state = turn(state, action)
    check(state.getPokemonState(ludiA).currentHP == 252)

  test "Grassium Z":
    var (state, venuH, venuA) = gameSetup(grassiumZ, grassiumZ)
    var action = @[state.attack(venuH, "Z-Energy Ball")]
    state = turn(state, action)
    check(state.getPokemonState(venuA).currentHP == 250)

  test "Electrium Z":
    var (state, pikaH, pikaA) = gameSetup(electriumZ, electriumZ)
    var action = @[state.attack(pikaH, "Z-Thunderbolt")]
    state = turn(state, action)
    check(state.getPokemonState(pikaA).currentHP == 108)

  test "Icium Z":
    var (state, glaceonH, glaceonA) = gameSetup(iciumZ, iciumZ)
    var action = @[state.attack(glaceonH, "Z-Blizzard")]
    state = turn(state, action)
    check(state.getPokemonState(glaceonA).currentHP == 129)

  test "Psychium Z":
    var (state, mewH, mewA) = gameSetup(psychiumZ, psychiumZ)
    var action = @[state.attack(mewH, "Z-Psychic")]
    state = turn(state, action)
    check(state.getPokemonState(mewA).currentHP == 238)

  test "Darkium Z":
    var (state, darkH, darkA) = gameSetup(darkiumZ, darkiumZ)
    var action = @[state.attack(darkH, "Z-Dark Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(darkA).currentHP == 148)

  test "Dragonium Z":
    var (state, dialgaH, dialgaA) = gameSetup(dragoniumZ, dragoniumZ)
    var action = @[state.attack(dialgaH, "Z-Dragon Pulse")]
    state = turn(state, action)
    check(state.getPokemonState(dialgaA).currentHP == 74)

  test "Fairium Z":
    var (state, sylfH, sylfA) = gameSetup(fairiumZ, fairiumZ)
    var action = @[state.attack(sylfH, "Z-Moonblast")]
    state = turn(state, action)
    check(state.getPokemonState(sylfA).currentHP == 153)
  
  test "Groundium Z":
    var (state, mudH, mudA) = gameSetup(groundiumZ, groundiumZ)
    var action = @[state.attack(mudH, "Z-Earthquake")]
    state = turn(state, action)
    check(state.getPokemonState(mudA).currentHP == 85)

  test "Steelium Z":
    var (state, metaH, metaA) = gameSetup(steeliumZ, steeliumZ)
    var action = @[state.attack(metaH, "Z-Meteor Mash")]
    state = turn(state, action)
    check(state.getPokemonState(metaA).currentHP == 196)

  test "Rockium Z":
    var (state, golemH, golemA) = gameSetup(rockiumZ, rockiumZ)
    var action = @[state.attack(golemH, "Z-Rock Slide")]
    state = turn(state, action)
    check(state.getPokemonState(golemA).currentHP == 225)

  test "Fightinium Z":
    var (state, luchaH, luchaA) = gameSetup(fightiniumZ, fightiniumZ)
    var action = @[state.attack(luchaH, "Z-High Jump Kick")]
    state = turn(state, action)
    check(state.getPokemonState(luchaA).currentHP == 162)

  test "Flyinium Z":
    var (state, skarmH, skarmA) = gameSetup(flyiniumZ, flyiniumZ)
    var action = @[state.attack(skarmH, "Z-Brave Bird")]
    state = turn(state, action)
    check(state.getPokemonState(skarmA).currentHP == 202)

  test "Buginium Z":
    var (state, beeH, beeA) = gameSetup(buginiumZ, buginiumZ)
    var action = @[state.attack(beeH, "Z-X-Scissor")]
    state = turn(state, action)
    check(state.getPokemonState(beeA).currentHP == 97)

  test "Poison Z":
    var (state, beeH, beeA) = gameSetup(poisoniumZ, poisoniumZ)
    var action = @[state.attack(beeH, "Z-Poison Jab")]
    state = turn(state, action)
    check(state.getPokemonState(beeA).currentHP == 97)

  test "Ghostium Z":
    var (state, mimiH, mimiA) = gameSetup(ghostiumZ, ghostiumZ)
    var action = @[state.attack(mimiH, "Z-Shadow Ball")]
    state = turn(state, action)
    check(state.getPokemonState(mimiA).currentHP == 42)

  test "Normalium Z":
    var (state, snorlaxH, snorlaxA) = gameSetup(normaliumZ, normaliumZ)
    var action = @[state.attack(snorlaxH, "Z-Body Slam")]
    state = turn(state, action)
    check(state.getPokemonState(snorlaxA).currentHP == 172)

  test "Aloraichium Z":
    var (state, zchu, chu) = gameSetup(aloraichiumZ, noZRaichu)
    var action = @[state.attack(zchu, "Stoked Sparksurfer")]
    state = turn(state, action)
    check(state.getPokemonState(chu).currentHP == 149)

  test "Eevium Z":
    var (state, zeevee, eevee) = gameSetup(eeviumZ, eeviumZ)
    var action = @[state.attack(zeevee, "Extreme Evoboost")]
    state = turn(state, action)
    action = @[state.attack(zeevee, "Hyper Voice")]
    state = turn(state, action)
    check(state.getPokemonState(eevee).currentHP == 91)

  test "Blazikenite":
    var (state, blazeH, blazeA) = gameSetup(blazikenite, blazikenite)
    var action = @[
      state.megaEvolve(blazeH),
      state.attack(blazeH, "Fire Blast")
    ]
    state = turn(state, action)
    checkHP(state, blazeA, 193)

  test "Charizardite Y":
    var (state, megaCharizard, charizard) = gameSetup(charizarditeY, charizarditeY)
    var actions = @[
      state.megaEvolve(megaCharizard),
      state.attack(megaCharizard, "Fire Blast")
    ]
    state = turn(state, actions)
    checkHP(state, charizard, 131)
    check(state.field.weather == fwkSun)
