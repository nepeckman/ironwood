import ../../src/engine/gameObjects/[pokemon, team, field]
import ../../src/engine/gameData/[pokemove, poketype]
import ../../src/engine/state

proc sanityState*(): State =
    var snorlaxStats: PokeStats = (hp: 244, atk: 178, def: 109, spa: 85, spd: 130, spe: 45)
    var move = PokeMove(
        name: "Return",
        category: pmcPhysical,
        basePower: 102,
        pokeType: ptNormal,
        priority: 0,
        modifiers: {}
        )
    var homePokemon = makePokemon("Snorlax", tskHome, ptNormal, stats = snorlaxStats, moves = @[move])
    var awayPokemon = makePokemon("Snorlax", tskAway, ptNormal, stats = snorlaxStats, moves = @[move])
    var homeTeam = makeTeam([homePokemon, nil, nil, nil, nil, nil], tskHome)
    var awayTeam = makeTeam([awayPokemon, nil, nil, nil, nil, nil], tskAway)
    State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
