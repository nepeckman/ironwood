import
  json, os, strutils,
  ../gameData/[effects, ability],
  effectParser, rawDataImporter

const abilitydexString = staticRead("rawdata/abilitydex" & fileSuffix)

let abilitydex = parseJson(abilitydexString)

proc getAbility*(name: string): Ability =
  if isNilOrWhitespace(name): return nil
  let abilityData = abilitydex[name]
  let effect = parseEffect(abilityData)
  newAbility(name, effect)
