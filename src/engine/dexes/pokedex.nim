import
  json, os,
  ../gameData/[pokemonData, poketype],
  dexutils

const pokedexString = staticRead("rawdata/pokedex" & fileSuffix)

let pokedex = parseJson(pokedexString)

proc getPokemonData*(name: string): PokemonData =
  let pokeData = pokedex[name]
  let statsJson = pokeData["bs"]
  let stats: PokeStats = (
    hp: statsJson["hp"].getInt(),
    atk: statsJson["at"].getInt(),
    def: statsJson["df"].getInt(),
    spa: statsJson["sa"].getInt(),
    spd: statsJson["sd"].getInt(),
    spe: statsJson["sp"].getInt()
  )
  let pokeType1 = 
    if pokeData.hasKey("t1"): toPokeType(pokeData["t1"].getStr())
    else: ptNull
  let pokeType2 =
    if pokeData.hasKey("t2"): toPokeType(pokeData["t2"].getStr())
    else: ptNull
  let weight = pokeData["w"].getFloat()

  newPokemonData(name, pokeType1, pokeType2, stats, weight, {})
