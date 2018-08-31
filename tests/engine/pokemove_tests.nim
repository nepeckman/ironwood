import ../../src/engine/[damage, pokemon, pokemove, team, state, field, poketype, action]
import unittest

suite "Regular moves":

  test "sanity check":
    var snorlaxStats: PokeStats = (hp: 244, atk: 178, def: 109, spa: 85, spd: 130, spe: 45)
    var attacker = makePokemon("Snorlax", ptNormal, stats = snorlaxStats)
    var defender = makePokemon("Snorlax", ptNormal, stats = snorlaxStats)
    var move = PokeMove(
        name: "Return",
        category: pmcPhysical,
        basePower: 102,
        pokeType: ptNormal,
        priority: 0,
        modifiers: {}
        )
    var homeTeam = makeTeam([attacker, attacker, attacker, attacker, attacker, attacker], tskHome)
    var awayTeam = makeTeam([defender, defender, defender, defender, defender, defender], tskAway)
    var gameState = State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())

    let damage = getDamageResult(attacker, defender, move, gameState)
    check(damage == [94, 96, 97, 99, 99, 100, 102, 103, 103, 105, 106, 108, 108, 109, 111, 112])
