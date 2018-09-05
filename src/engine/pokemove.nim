#TODO: Make moves immutable data
import strutils
import poketype, field, item, ability, effects

type

  PokeMoveModifiers* = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn, pmmMakesContact, pmmPunch, pmmJaw, pmmSpread, pmmSecondaryEffect, pmmPulse,
    pmmHeals, pmmBypassesProtect, pmmIgnoresDefenseBoosts, pmmRecoil, pmmSelfKOs, pmmVariablePower, pmmConsistentDamage
  
  PokeMoveCategory* = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMove* = ref object 
    name*: string
    category*: PokeMoveCategory
    basePower*: int
    effect: Effect
    pokeType*: PokeType
    priority*: int
    modifiers*: set[PokeMoveModifiers]


proc copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    basePower: move.basePower,
    effect: move.effect,
    pokeType: move.pokeType,
    priority: move.priority,
    modifiers: move.modifiers
  )

proc `==`*(move: PokeMove, s: string): bool =
  if isNil(move): "" == s else: move.name == s

proc `==`*(s: string, move: PokeMove): bool =
  if isNil(move): "" == s else: move.name == s

proc `contains`*(arr: openArray[string], move: PokeMove): bool =
  if isNil(move): false else: find(arr, move.name) >= 0

proc isItemDependant*(move: PokeMove): bool =
  move.name in ["Judgement", "Techno Blast", "Multi-Attack", "Natural Gift"]

proc isAuraBoosted*(move: PokeMove, field: Field): bool =
  (fakDark in field.auras and move.pokeType == ptDark) or
    (fakFairy in field.auras and move.pokeType == ptFairy)

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
  if item.kind in {ikDrive, ikPlate, ikMemory}:
    move.pokeType = item.associatedType

proc naturePowerTransformation*(move: PokeMove, terrain: FieldTerrainKind) =
  move.pokeType = case terrain
    of ftkElectric: ptElectric
    of ftkPsychic: ptPsychic
    of ftkGrass: ptGrass
    of ftkFairy: ptFairy
    else: ptNormal
  move.basePower = case terrain
    of ftkElectric: 90
    of ftkPsychic: 90
    of ftkGrass: 90
    of ftkFairy: 95
    else: 80

proc weatherBallTransformation*(move: PokeMove, weather: FieldWeatherKind) =
  move.pokeType = case weather
    of fwkSun, fwkHarshSun: ptFire
    of fwkRain, fwkHeavyRain: ptWater
    of fwkSand: ptRock
    of fwkHail: ptIce
    else: ptNormal
  move.basePower = if weather == fwkNone or weather == fwkStrongWinds: 50 else: 100

proc speedRatioToBasePower*(speedRatio: float): int =
  if speedRatio >= 4: 150
  elif speedRatio >= 3: 120
  elif speedRatio >= 2: 80
  else: 60

proc weightToBasePower*(weight: int): int =
  if weight >= 200: 120
  elif weight >= 100: 100
  elif weight >= 50: 80
  elif weight >= 25: 60
  elif weight >= 10: 40
  else: 20

proc weightRatioToBasePower*(weightRatio: float): int =
  if weightRatio >= 5: 120
  elif weightRatio >= 4: 100
  elif weightRatio >= 3: 80
  elif weightRatio >= 2: 60
  else: 40

proc healthRatioToBasePower*(healthRatio: float): int =
  if healthRatio <= 1: 200
  elif healthRatio <= 4: 150
  elif healthRatio <= 9: 100
  elif healthRatio <= 16: 80
  elif healthRatio <= 32: 40
  else: 20
