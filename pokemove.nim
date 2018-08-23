import strutils
import poketype, field, item, ability

type

  PokeMoveModifiers* = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn, pmmMakesContact, pmmPunch, pmmJaw, pmmSpread, pmmSecondaryEffect, pmmPulse,
    pmmHeals, pmmBypassesProtect, pmmIgnoresDefenseBoosts
  
  PokeMoveCategory* = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMove* = ref object 
    name*: string
    category*: PokeMoveCategory
    basePower*: int
    pokeType*: PokeType
    priority*: int
    modifiers*: set[PokeMoveModifiers]

proc isItemDependant*(move: PokeMove): bool =
  move.name in ["Judgement", "Techno Blast", "Multi-Attack", "Natural Gift"]

proc copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    basePower: move.basePower,
    pokeType: move.pokeType,
    priority: move.priority,
    modifiers: move.modifiers
  )

proc changeTypeWithAbility*(move: PokeMove, ability: Ability) =
  if move.pokeType == ptNormal:
    if ability == "Aerilate":
      move.pokeType = ptFlying
      move.modifiers.incl(pmmAerilated)
    elif ability == "Pixilate":
      move.pokeType = ptFairy
      move.modifiers.incl(pmmPixilated)
    elif ability == "Refrigerate":
      move.pokeType = ptIce
      move.modifiers.incl(pmmRefrigerated)
    elif ability == "Galvanize":
      move.pokeType = ptElectric
      move.modifiers.incl(pmmGalvanized)
    elif ability == "Liquid Voice" and pmmSound in move.modifiers:
      move.pokeType = ptWater
  elif ability == "Normalize":
    move.pokeType = ptNormal

proc changeTypeWithItem*(move: PokeMove, item: Item) =
  if move.name == "Judgement" and item.kind == ikPlate:
    move.pokeType = item.associatedType
  if move.name == "Techno Blast" and item.kind == ikDrive:
    move.pokeType = item.associatedType

proc changeTypeWithTerrain*(move: PokeMove, terrain: FieldTerrainKind) =
  move.pokeType = case terrain
    of ftkElectric: ptElectric
    of ftkPsychic: ptPsychic
    of ftkGrass: ptGrass
    of ftkFairy: ptFairy
    else: ptNormal

proc changeTypeWithWeather*(move: PokeMove, weather: FieldWeatherKind) =
  move.pokeType = case weather
    of fwkSun, fwkHarshSun: ptFire
    of fwkRain, fwkHeavyRain: ptWater
    of fwkSand: ptRock
    of fwkHail: ptIce
    else: ptNormal
  move.basePower = if weather == fwkNone or weather == fwkStrongWinds: 50 else: 100
