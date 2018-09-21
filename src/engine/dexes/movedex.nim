import
  json, os,
  ../gameData/[pokemove, poketype, effects],
  effectParser, rawDataImporter

const movedexString = staticRead("rawdata/movedex" & fileSuffix)

let movedex = parseJson(movedexString)
  
proc getPokeMove*(name: string): PokeMove =
  #TODO: handle missing move
  let moveData = movedex[name]
  let category = 
    if moveData.hasKey("category"):
      toPokeMoveCategory(moveData["category"].getStr())
    else: pmcStatus
  let basePower = moveData["bp"].getInt()
  let pokeType = moveData["type"].getStr().toPokeType()
  let target = 
    if moveData.hasKey("targets"):
      toPokeMoveTarget(moveData["targets"].getStr())
    else: pmtSelectedTarget
  let effect = parseEffect(moveData)
  newMove(name, category, target, basePower, effect, pokeType, 0, {})
