import tables, strutils
import field, item, poketype

type

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeEffect* = enum
    peAsleep, peConfused, pePoisoned, peBurned, peParalyzed

  PokeMoveModifiers* = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn
  
  PokeMoveCategory* = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMoveEffectKind = enum
    pmekBoost, pmekStatus

  PokeMoveEffect = ref object
    case kind: PokeMoveEffectKind
    of pmekBoost: boosts: PokeStats
    of pmekStatus: status: PokeEffect

  PokeMove* = ref object 
    name*: string
    category*: PokeMoveCategory
    basePower*: int
    pokeType*: PokeType
    priority*: int
    effect*: PokeMoveEffect
    modifiers*: set[PokeMoveModifiers]

  Pokemon* = ref object
    name*: string
    pokeType1*: PokeType
    pokeType2*: PokeType
    ability*: string
    level*: int
    item*: string
    stats*: PokeStats
    weight*: float
    currentHP*: int
    boosts*: PokeStats
    effects*: set[PokeEffect]


proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon): float =
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, attacker.ability == "Scrappy") *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, attacker.ability == "Scrappy")

proc hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item == "Air Balloon")

proc getWeightFactor*(pokemon: Pokemon): float =
  if pokemon.ability == "Heavy Metal": 2f
  elif pokemon.ability == "Light Metal": 0.5
  else: 1f

proc hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]

proc isItemDependant*(move: PokeMove): bool =
  move.name in ["Judgement", "Techno Blast", "Multi-Attack", "Natural Gift"]

proc copy*(move: PokeMove): PokeMove =
  PokeMove(
    name: move.name,
    category: move.category,
    basePower: move.basePower,
    pokeType: move.pokeType,
    priority: move.priority,
    effect: move.effect,
    modifiers: move.modifiers
  )

proc changeTypeWithAbility*(move: PokeMove, ability: string) =
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

proc changeTypeWithItem*(move: PokeMove, item: string) =
  if move.name == "Judgement" and item.find("Plate") != -1:
    move.pokeType = getItemBoostType(item)
  if move.name == "Techno Blast" and item.find("Drive") != -1:
    move.pokeType = getTechnoBlast(item)

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

proc changePriority*(move: PokeMove, pokemon: Pokemon) =
  if pokemon.ability == "Gale Wings" and move.pokeType == ptFlying and
    pokemon.currentHP == pokemon.stats.hp: 
    move.priority = move.priority + 1


proc skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move.name == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Dream Eater" and
    not (peAsleep in defender.effects) and
    defender.ability != "Comatose"
