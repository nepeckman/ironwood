import
  json, os, tables,
  ../gameData/[pokemonData, poketype, ability, pokeStats],
  abilitydex, dexutils

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
  let ability =
    if pokeData.hasKey("ab"): getAbility(pokeData["ab"].getStr())
    else: nil

  result = newPokemonData(name, pokeType1, pokeType2, stats, ability, weight, {})

proc getFormeData*(name: string): Table[string, PokemonData] =
  result = initTable[string, PokemonData]()
  let pokeData = pokedex[name]
  if pokeData.hasKey("formes") and pokeData["formes"].kind == JArray:
    for forme in pokeData["formes"]:
      result[forme.getStr()] = getPokemonData(forme.getStr())
