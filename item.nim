import poketype, field

type

  ItemKind* = enum
    ikResistBerry, ikGem, ikTypeBoost, ikPlate, ikMegaStone, ikZCrystal, ikTerrainSeed,
    ikPinchBerry , ikChoiceScarf, ikChoiceBand, ikChoiceSpecs, ikLifeOrb,
    ikLeftovers, ikShellBell, ikPokemonExclusive, ikAirBalloon, ikFocusSash,
    ikEviolite, ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb, ikRockyHelmet,
    ikDrive, ikMemory, ikSafetyGoggles, ikEjectButton, ikMuscleBand, ikWiseGlasses, ikExpertBelt

  Item* = ref object
    consumable*: bool
    name*: string
    case kind*: ItemKind
    of ikResistBerry: resistedType*: PokeType
    of ikGem, ikTypeBoost, ikZCrystal, ikDrive, ikMemory, ikPlate: associatedType*: PokeType
    of ikTerrainSeed: associatedTerrain*: FieldTerrainKind
    of ikPinchBerry: activationPercent*, restorePercent*: int
    of ikMegaStone, ikPokemonExclusive: associatedPokemonName*: string
    of ikChoiceScarf, ikChoiceBand, ikChoiceSpecs, ikLifeOrb, ikLeftovers, ikShellBell, ikAirBalloon, ikFocusSash, ikEviolite,
      ikAssaultVest, ikRingTarget, ikRedCard, ikWhiteHerb, ikPowerHerb,
      ikRockyHelmet, ikSafetyGoggles, ikEjectButton, ikMuscleBand,
      ikWiseGlasses, ikExpertBelt: discard
    

proc getItemBoostType*(item: string): PokeType =
  case item 
  of "Draco Plate", "Dragon Fang": ptDragon
  of "Dread Plate", "Black Glasses": ptDark
  of "Earth Plate", "Soft Sand": ptGround
  of "Fist Plate", "Black Belt": ptFighting
  of "Flame Plate", "Charcoal": ptFire
  of "Icicle Plate", "Never-Melt Ice": ptIce
  of "Insect Plate", "Silver Powder": ptBug
  of "Iron Plate", "Metal Coat": ptSteel
  of "Meadow Plate", "Rose Incense", "Miracle Seed": ptGrass
  of "Mind Plate", "Odd Incense", "Twisted Spoon": ptPsychic
  of "Pixie Plate": ptFairy
  of "Sky Plate", "Sharp Beak": ptFlying
  of "Splash Plate", "Sea Incense", "Wave Incense", "Mystic Water": ptWater
  of "Spooky Plate", "Spell Tag": ptGhost
  of "Stone Plate", "Rock Incense", "Hard Stone": ptRock
  of "Toxic Plate", "Poison Barb": ptPoison
  of "Zap Plate", "Magnet": ptElectric
  of "Silk Scarf", "Pink Bow", "Polkadot Bow": ptNormal
  else: ptNull

proc getTechnoBlast*(item: string): PokeType =
  case item
  of "Burn Drive": ptFire
  of "Chill Drive": ptIce
  of "Douse Drive": ptWater
  of "Shock Drive": ptElectric
  else: ptNull
