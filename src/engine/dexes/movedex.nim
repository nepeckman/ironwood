import
  json, os,
  ../gameData/[pokemove, poketype, effects]

const movedexString = staticRead("rawdata/movedex.min.json")

let movedex = parseJson(movedexString)

proc parseBoostChange(boostData: JsonNode):
                        tuple[atk: int, def: int, spa: int, spd: int, spe: int] =
  var atk, def, spa, spd, spe = 0
  if boostData.hasKey("atk"):
    atk = boostData["atk"].getInt()
  if boostData.hasKey("def"):
    def = boostData["def"].getInt()
  if boostData.hasKey("spa"):
    spa = boostData["spa"].getInt()
  if boostData.hasKey("spd"):
    spd = boostData["spd"].getInt()
  if boostData.hasKey("spe"):
    spe = boostData["spe"].getInt()
  (atk: atk, def: def, spa: spa, spd: spd, spe: spe)

proc parseEffect(moveData: JsonNode): Effect =
  let target =
    if moveData.hasKey("effectTargets"):
      toEffectTarget(moveData["effectTargets"].getStr())
    else: etkPokemon
  if moveData.hasKey("boostChange"):
    let boosts = parseBoostChange(moveData["boostChange"])
    newBoostEffect(target, boosts)
  else: nil
  
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
