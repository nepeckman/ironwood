import
  json, os,
  ../gameData/[pokemove, poketype]

const movedexString = staticRead("rawdata/movedex.json")

let movedex = parseJson(movedexString)

proc getPokeMove*(name: string): PokeMove =
  #TODO: handle missing move
  let jsonData = movedex[name]
  let category = toPokeMoveCategory(jsonData["category"].getStr())
  let basePower = jsonData["bp"].getInt()
  let pokeType = jsonData["type"].getStr().toPokeType()
  newMove(name, category, basePower, nil, pokeType, 0, {})
