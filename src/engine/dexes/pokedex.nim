import
  json, os,
  ../gameData/[pokemonData, poketype]

const pokedexString = staticRead("rawdata/pokedex.json")

let pokedex = parseJson(pokedexString)

proc getPokemonData*(name: string): PokemonData =
  #TODO: handle missing pokemon
  let jsonData = pokedex[name]
  let statsJson = jsonData["bs"]
  let stats: PokeStats = (
    hp: statsJson["hp"].getInt(),
    atk: statsJson["at"].getInt(),
    def: statsJson["df"].getInt(),
    spa: statsJson["sa"].getInt(),
    spd: statsJson["sd"].getInt(),
    spe: statsJson["sp"].getInt()
  )
  let pokeType1 = 
    if jsonData.hasKey("t1"): toPokeType(jsonData["t1"].getStr())
    else: ptNull
  let pokeType2 =
    if jsonData.hasKey("t2"): toPokeType(jsonData["t2"].getStr())
    else: ptNull
  let weight = jsonData["w"].getFloat()

  newPokemonData(name, pokeType1, pokeType2, stats, weight, {})
