import
  json, os,
  ../gameData/[pokemove, poketype]

const movedexString = staticRead("rawdata/movedex.json")

let movedex = parseJson(movedexString)

proc getPokeMove*(name: string): PokeMove =
  #TODO: handle missing move
  let jsonData = movedex[name]
  let category = 
    if jsonData.hasKey("category"):
      toPokeMoveCategory(jsonData["category"].getStr())
    else: pmcStatus
  let basePower = jsonData["bp"].getInt()
  let pokeType = jsonData["type"].getStr().toPokeType()
  newMove(name, category, pmtSelectedTarget, basePower, nil, pokeType, 0, {})
