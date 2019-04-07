import
  json, os, strutils,
  ../gameData/[item, poketype, pokemove],
  dexutils, effectParser, movedex

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
  of ikCustomZCrystal: newCustomZCrystal(name, getPokeMove(itemData["zMove"].getStr()), itemData["associatedMove"].getStr(), itemData["pokemon"].getStr())
  of ikPinchBerry: newPinchBerry(name, itemData["activationPercent"].getInt(), effect)
  of ikResistBerry: newResistBerry(name, toPokeType(itemData["associatedType"].getStr()))
  of ikMegaStone: newMegaStone(name, itemData["basePokemon"].getStr(), itemData["megaPokemon"].getStr())
  else: newUniqueItem(name, effect, consumable)
