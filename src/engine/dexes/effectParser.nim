import
  json,
  ../gameData/gameData

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

proc parseEffect*(data: JsonNode): Effect =
  let target =
    if data.hasKey("effectTargets"): toEffectTarget(data["effectTargets"].getStr())
    else: etkPokemon
  let activation =
    if data.hasKey("activation"): toEffectActivation(data["activation"].getStr())
    else: eakPassive

  if data.hasKey("boostChange"):
    let boosts = parseBoostChange(data["boostChange"])
    newBoostEffect(target, boosts, activation)
  elif data.hasKey("weatherChange"):
    newWeatherEffect(toWeather(data["weatherChange"].getStr()), activation)
  else: nil
