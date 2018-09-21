import
  json, os, strutils,
  ../gameData/[effects, ability],
  effectParser, rawDataImporter

const abilitydexString = staticRead("rawdata/abilitydex" & fileSuffix)

let abilitydex = parseJson(abilitydexString)

proc getAbility*(name: string): Ability =
  if isNilOrWhitespace(name): return nil
  var abilityData: JsonNode
  try:
    abilityData = abilitydex[name]
  except KeyError:
    return newAbility(name, nil)
  let effect = parseEffect(abilityData)
  newAbility(name, effect)
