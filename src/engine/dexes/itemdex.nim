import
  json, os, strutils,
  ../gameData/[item],
  rawDataImporter

const itemdexstring = staticRead("rawdata/itemdex" & fileSuffix)

let itemdex = parseJson(itemdexstring)

proc getItem*(name: string): Item =
  if isNilOrWhitespace(name): return nil
  var itemData: JsonNode
  try:
    itemData = idemdex[name]
  except KeyError:
    return newItem(name)
  item(name)
