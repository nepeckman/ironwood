import strutils
import poketype, field

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
    of ikResistBerry: resistedType*: PokeType
    of ikGem, ikTypeBoost, ikZCrystal, ikDrive, ikMemory, ikPlate: associatedType*: PokeType
    of ikTerrainSeed: associatedTerrain*: FieldTerrainKind
    of ikPinchBerry: activationPercent*, restorePercent*: int
    of ikMegaStone, ikPokemonExclusive: associatedPokemonName*: string
    of ikChoiceScarf, ikChoiceBand, ikChoiceSpecs, ikLifeOrb, ikLeftovers, ikShellBell, ikAirBalloon, ikFocusSash, ikEviolite,
      ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb,
      ikRockyHelmet, ikSafetyGoggles, ikEjectButton, ikMuscleBand,
      ikWiseGlasses, ikExpertBelt, ikNone: discard

proc getFlingPower*(item: Item): int =
  if item.name == "Iron Ball": 130
  elif item.name == "Hard Stone": 100
  elif item.kind == ikPlate or item.name in ["Deep Sea Tooth", "Thick Club"]: 90
  elif item.name in ["Assault Vest", "Weakness Policy"]: 80
  elif item.name in ["Poison Barb", "Dragon Fang"]: 70
  elif item.name in ["Adamant Orb", "Lustrous Orb", "Macho Brace", "Stick"]: 60
  elif item.name == "Sharp Beak": 50
  elif item.name == "Eviolite": 40
  elif item.name in ["Black Belt", "Black Sludge", "Black Glasses", "Charcoal", "Deep Sea Scale", "Flame Orb", "King's Rock",
    "Life Orb", "Light Ball", "Magnet", "Metal Coat", "Miracle Seed", "Mystic Water", "Never-Melt Ice",
    "Razor Fang", "Soul Dew", "Spell Tag", "Toxic Orb", "Twisted Spoon"]: 30
  elif item.name.find("Berry") != -1 or item.name in ["Air Balloon", "Choice Band",
  "Choice Scarf", "Choice Specs", "Destiny Knot", "Electric Seed", "Expert Belt",
  "Focus Band", "Focus Sash", "Grassy Seed", "Lagging tail", "leftovers", "Mental Herb",
  "Metal Powder", "Misty Seed", "Muscle Band", "Power Herb", "Psychic Seed", "Quick Powder",
  "Reaper Cloth", "Red Card", "Ring Target", "Shed Shell", "Silk Scarf", "Silver Powder",
  "Smooth Rock", "Soft Sand", "Soothe Bell", "White Herb", "Wide Lens", "Wise Glasses", "Zoom Lens"]: 10
  else: 0

proc kind*(item: Item): ItemKind =
  if item == nil: ikNone else: item.kind

proc name*(item: Item): string =
  if item == nil: "" else: item.name

proc consumable*(item: Item): bool =
  if item == nil: false else: item.consumable
