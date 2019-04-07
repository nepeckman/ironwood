import
  json, os,
  ../gameData/[pokemove, poketype, effects],
  effectParser, dexutils

const movedexString = staticRead("rawdata/movedex" & fileSuffix)

let movedex = parseJson(movedexString)
  
proc getPokeMove*(name: string): PokeMove =
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
  let effect =
    if moveData.hasKey("effect"): parseEffect(moveData["effect"])
    else: nil
  let isZ =
    if moveData.hasKey("isZ"): moveData["isZ"].getBool()
    else: false
  let zPower =
    if moveData.hasKey("zp"): moveData["zp"].getInt()
    else: 0
  let priority =
    if moveData.hasKey("priority"): moveData["priority"].getInt()
    else: 0
  newMove(name, category, target, basePower, effect, pokeType, priority, {}, zPower, nil, isZ)
