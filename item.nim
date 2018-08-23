import poketype

type

  ItemEffectKind = enum
    iekResistBerry, iekGem, iekTypeBoost, iekMegaStone, iekZCrystal, iekTerrainSeed,
    iekPinchBerry, iekChoiceScarf, iekChoiceBand, iekChoiceSpecs, iekLifeOrb,
    iekLeftovers, iekShellBell, iekPokemonExclusive, iekAirBalloon, iekFocusSash, iekFocusBand,
    iekEviolite, iekAssaultVest, iekRingTarget, iekRedCard, iekWhiteHerb, iekPowerHerb, iekRockyHelmet,
    iekDrive, iekMemory, iekSafetyGoggles, iekEjectButton, iekMuscleBand, iekWiseGlasses, iekMetalPowder,
    iekExpertBelt

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
