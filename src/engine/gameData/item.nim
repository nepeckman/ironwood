import strutils
import poketype, fieldConditions

type

  ItemKind* = enum
    ikResistBerry, ikGem, ikTypeBoost, ikPlate, ikMegaStone, ikZCrystal, ikTerrainSeed,
    ikPinchBerry , ikChoiceScarf, ikChoiceBand, ikChoiceSpecs, ikLifeOrb,
    ikLeftovers, ikShellBell, ikPokemonExclusive, ikAirBalloon, ikFocusSash,
    ikEviolite, ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb, ikRockyHelmet,
    ikDrive, ikMemory, ikSafetyGoggles, ikEjectButton, ikMuscleBand, ikWiseGlasses, ikExpertBelt, ikNone

  Item* = ref object
    consumable: bool
    name: string
    case kind: ItemKind
    of ikGem, ikTypeBoost, ikZCrystal, ikResistBerry,
      ikDrive, ikMemory, ikPlate: associatedType: PokeType
    of ikTerrainSeed: associatedTerrain: FieldTerrainKind
    of ikPinchBerry: activationPercent, restorePercent: int
    of ikMegaStone, ikPokemonExclusive: associatedPokemonName: string
    of ikChoiceScarf, ikChoiceBand, ikChoiceSpecs, ikLifeOrb, ikLeftovers, ikShellBell, ikAirBalloon, ikFocusSash, ikEviolite,
      ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb,
      ikRockyHelmet, ikSafetyGoggles, ikEjectButton, ikMuscleBand,
      ikWiseGlasses, ikExpertBelt, ikNone: discard

proc kind*(item: Item): ItemKind =
  if isNil(item): ikNone else: item.kind

proc name*(item: Item): string =
  if isNil(item): "" else: item.name

proc consumable*(item: Item): bool =
  if isNil(item): false else: item.consumable

proc associatedType*(item: Item): PokeType = item.associatedType
proc associatedTerrain*(item: Item): FieldTerrainKind = item.associatedTerrain
proc activationPercent*(item: Item): int = item.activationPercent
proc restorePercent*(item: Item): int = item.restorePercent
proc associatedPokemonName*(item: Item): string = item.associatedPokemonName

proc `==`*(item: Item, s: string): bool =
  if isNil(item): "" == s else: item.name == s

proc `==`*(s: string, item: Item): bool =
  if isNil(item): "" == s else: item.name == s

proc `contains`*(arr: openArray[string], item: Item): bool =
  if isNil(item): false else: find(arr, item.name) >= 0

proc find*(item: Item, s: string): int = item.name.find(s)

proc getFlingPower*(item: Item): int =
  if item == "Iron Ball": 130
  elif item == "Hard Stone": 100
  elif item.kind == ikPlate or item in ["Deep Sea Tooth", "Thick Club"]: 90
  elif item in ["Assault Vest", "Weakness Policy"]: 80
  elif item in ["Poison Barb", "Dragon Fang"]: 70
  elif item in ["Adamant Orb", "Lustrous Orb", "Macho Brace", "Stick"]: 60
  elif item == "Sharp Beak": 50
  elif item == "Eviolite": 40
  elif item in ["Black Belt", "Black Sludge", "Black Glasses", "Charcoal", "Deep Sea Scale", "Flame Orb", "King's Rock",
    "Life Orb", "Light Ball", "Magnet", "Metal Coat", "Miracle Seed", "Mystic Water", "Never-Melt Ice",
    "Razor Fang", "Soul Dew", "Spell Tag", "Toxic Orb", "Twisted Spoon"]: 30
  elif item.name.find("Berry") != -1 or item in ["Air Balloon", "Choice Band",
  "Choice Scarf", "Choice Specs", "Destiny Knot", "Electric Seed", "Expert Belt",
  "Focus Band", "Focus Sash", "Grassy Seed", "Lagging tail", "leftovers", "Mental Herb",
  "Metal Powder", "Misty Seed", "Muscle Band", "Power Herb", "Psychic Seed", "Quick Powder",
  "Reaper Cloth", "Red Card", "Ring Target", "Shed Shell", "Silk Scarf", "Silver Powder",
  "Smooth Rock", "Soft Sand", "Soothe Bell", "White Herb", "Wide Lens", "Wise Glasses", "Zoom Lens"]: 10
  else: 0

