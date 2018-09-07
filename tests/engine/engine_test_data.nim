import ../../src/engine/gameObjects/gameObjects
import ../../src/engine/gameData/gameData
import ../../src/engine/engine

proc sanityState*(): State =
    var returnMove = PokeMove(
        name: "Return",
        category: pmcPhysical,
        basePower: 102,
        pokeType: ptNormal,
        priority: 0,
        modifiers: {}
        )
    var snorlaxData = PokemonData(
      name: "Snorlax",
      pokeType1: ptNormal,
      pokeType2: ptNull,
      baseStats: (hp: 160, atk: 110, def: 65, spa: 65, spd: 110, spe: 30),
      weight: 460,
      dataFlags: {}
    )
    var snorlaxSet = PokemonSet(
      moves: @[returnMove],
      level: 50,
      item: nil,
      gender: pgkFemale,
      ability: nil,
      evs: (hp: 68, atk: 252, def: 188, spa: 0, spd: 0, spe: 0),
      ivs: (hp: 31, atk: 31, def: 31, spa: 31, spd: 31, spe: 31),
      nature: pnAdamant
    )
    var homePokemon = makePokemon(snorlaxData, snorlaxSet, tskHome)
    var awayPokemon = makePokemon(snorlaxData, snorlaxSet, tskAway)
    var homeTeam = makeTeam([homePokemon, nil, nil, nil, nil, nil], tskHome)
    var awayTeam = makeTeam([awayPokemon, nil, nil, nil, nil, nil], tskAway)
    State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
