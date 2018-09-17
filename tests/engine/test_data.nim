import ../../src/engine/engine

proc sanityState*(): State =
    var returnMove = getPokeMove("Return")
    var snorlaxData = getPokemonData("Snorlax")
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
    var homeTeam = makeTeam(@[homePokemon, nil, nil, nil, nil, nil], tskHome)
    var awayTeam = makeTeam(@[awayPokemon, nil, nil, nil, nil, nil], tskAway)
    State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())
