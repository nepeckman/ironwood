import
  json, os, strutils,
  ../gameData/[item, poketype],
  dexutils, effectParser

const itemdexstring = staticRead("rawdata/itemdex" & fileSuffix)

let itemdex = parseJson(itemdexstring)

proc getItem*(name: string): Item =
  if isNilOrWhitespace(name): return nil
  var itemData: JsonNode
  try:
    itemData = itemdex[name]
  except KeyError:
    return newUniqueItem(name)
  let kind = toItemKind(itemData["kind"].getStr())
  let consumable = itemData.hasKey("isConsumable")
  let effect =
    if itemData.hasKey("effect"): parseEffect(itemData["effect"])
    else: nil

  return case kind
  of ikZCrystal: newZCrystal(name, toPokeType(itemData["type"].getStr()))
  of ikPinchBerry: newPinchBerry(name, itemData["activationPercent"].getInt(), effect)
  else: newUniqueItem(name, effect, consumable)
