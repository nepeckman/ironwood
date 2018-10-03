import strutils
import poketype, fieldConditions

type

  ItemKind* = enum
    ikResistBerry, ikGem, ikTypeBoost, ikPlate, ikMegaStone, ikZCrystal, ikCustomZCrystal,
    ikTerrainSeed, ikPinchBerry , ikLifeOrb, ikLeftovers, ikShellBell, ikPokemonExclusive, ikFocusSash,
    ikEviolite, ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb, ikRockyHelmet,
    ikDrive, ikMemory, ikSafetyGoggles, ikEjectButton, ikExpertBelt, ikUnique

  Item* = ref object
    consumable: bool
    name: string
    case kind: ItemKind
    of ikGem, ikTypeBoost, ikResistBerry, ikZCrystal,
      ikDrive, ikMemory, ikPlate: associatedType: PokeType
    of ikTerrainSeed: associatedTerrain: FieldTerrainKind
    of ikPinchBerry: activationPercent, restorePercent: int
    of ikMegaStone, ikPokemonExclusive: associatedPokemonName: string
    of ikCustomZCrystal: 
      pName, pMove: string
      pType: PokeType
    of ikLifeOrb, ikLeftovers, ikShellBell, ikFocusSash, ikEviolite,
      ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb,
      ikRockyHelmet, ikSafetyGoggles, ikEjectButton, ikExpertBelt, ikUnique: discard

func newItem*(name: string, consumable = false, kind = ikUnique): Item =
  Item(name: name, consumable: consumable, kind: kind)

func kind*(item: Item): ItemKind =
  if isNil(item): ikUnique else: item.kind

func name*(item: Item): string =
  if isNil(item): "" else: item.name

func consumable*(item: Item): bool =
  if isNil(item): false else: item.consumable

func associatedType*(item: Item): PokeType = item.associatedType
func associatedTerrain*(item: Item): FieldTerrainKind = item.associatedTerrain
func activationPercent*(item: Item): int = item.activationPercent
func restorePercent*(item: Item): int = item.restorePercent
func associatedPokemonName*(item: Item): string = item.associatedPokemonName

func `==`*(item: Item, s: string): bool =
  if isNil(item): "" == s else: item.name == s

func `==`*(s: string, item: Item): bool =
  if isNil(item): "" == s else: item.name == s

func `contains`*(arr: openArray[string], item: Item): bool =
  if isNil(item): false else: find(arr, item.name) >= 0

func find*(item: Item, s: string): int = item.name.find(s)

func getFlingPower*(item: Item): int =
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

