import
  json, os, strutils,
  ../gameData/[item, poketype],
  rawDataImporter

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

  return case kind
  of ikZCrystal: newZCrystal(name, toPokeType(itemData["type"].getStr()))
  else: newUniqueItem(name)
