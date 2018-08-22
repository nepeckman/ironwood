import tables

type
  PokeType* = enum
    ptWater, ptFire, ptElectric, ptDark, ptPsychic, ptGrass, ptIce, ptDragon, ptFairy,
    ptNormal, ptFighting, ptRock, ptGround, ptSteel, ptGhost, ptPoison, ptBug, ptFlying,
    ptNull

  PokeStats* = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeEffect* = enum
    peAsleep, peConfused, pePoisoned, peBurned, peParalyzed

  PokeState* = ref object
    boosts*: PokeStats
    effects*: set[PokeEffect]
    currentHP*: int

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
    state*: PokeState


var PokeTypeEffectiveness = {
  ptWater: {ptWater: 0.5, ptFire: 2d, ptGrass: 0.5, ptDragon: 0.5, ptRock: 2d, ptGround: 2d}.toTable,
  ptFire: {ptWater: 0.5, ptFire: 0.5, ptGrass: 2d, ptIce: 2d, ptDragon: 0.5, ptRock: 0.5, ptSteel: 2d, ptBug: 2d}.toTable,
  ptElectric: {ptWater: 2d, ptElectric: 0.5, ptGrass: 0.5, ptDragon: 0.5, ptGround: 0d, ptFlying: 2d}.toTable,
  ptDark: {ptDark: 0.5, ptPsychic: 2d, ptFairy: 0.5, ptFighting: 0.5, ptGhost: 2d}.toTable,
  ptPsychic: {ptDark: 0d, ptPsychic: 0.5, ptFighting: 2d, ptSteel: 0.5, ptPoison: 2d}.toTable,
  ptGrass: {ptWater: 2d, ptFire: 0.5, ptGrass: 0.5, ptDragon: 0.5, ptRock: 2d, ptGround: 2d, ptSteel: 0.5, ptPoison: 0.5, ptBug: 0.5, ptFlying: 0.5}.toTable,
  ptIce: {ptWater: 0.5, ptFire: 0.5, ptGrass: 2d, ptIce: 0.5, ptDragon: 2d, ptGround: 2d, ptSteel: 0.5, ptFlying: 2d}.toTable,
  ptDragon: {ptDragon: 2d, ptFairy: 0d, ptSteel: 0.5}.toTable,
  ptFairy: {ptFire: 0.5, ptDark: 2d, ptDragon: 2d, ptFighting: 2d, ptSteel: 0.5, ptPoison: 0.5}.toTable,
  ptNormal: {ptSteel: 0.5, ptGhost: 0d}.toTable,
  ptFighting: {ptDark: 2d, ptPsychic: 0.5, ptIce: 2d, ptFairy: 0.5, ptNormal: 2d, ptRock: 2d, ptSteel: 2d, ptGhost: 0d, ptPoison: 0.5, ptBug: 0.5, ptFlying: 0.5}.toTable,
  ptRock: {ptFire: 2d, ptIce: 2d, ptFighting: 0.5, ptGround: 0.5, ptSteel: 0.5, ptBug: 2d, ptFlying: 2d}.toTable,
  ptGround: {ptFire: 2d, ptElectric: 2d, ptGrass: 0.5, ptRock: 2d, ptSteel: 2d, ptPoison: 2d, ptBug: 0.5, ptFlying: 0d}.toTable,
  ptSteel: {ptWater: 0.5, ptFire: 0.5, ptElectric: 0.5, ptIce: 2d, ptFairy: 2d, ptRock: 2d, ptSteel: 0.5}.toTable,
  ptGhost: {ptDark: 0.5, ptPsychic: 2d, ptNormal: 0d, ptGhost: 2d}.toTable,
  ptPoison: {ptGrass: 2d, ptFairy: 2d, ptGround: 0.5, ptSteel: 0d, ptPoison: 0.5}.toTable,
  ptBug: {ptFire: 0.5, ptDark: 2d, ptPsychic: 2d, ptGrass: 2d, ptFairy: 0.5, ptFighting: 0.5, ptRock: 0.5, ptSteel: 0.5, ptPoison: 0.5, ptFlying: 0.5}.toTable,
  ptFlying: {ptElectric: 0.5, ptGrass: 2d, ptFighting: 2d, ptRock: 0.5, ptSteel: 0.5, ptBug: 2d}.toTable,
  ptNull: initTable[PokeType, float]()
  }.toTable

proc getTypeMatchup*(attackerType, defenderType: PokeType): float =
  if defenderType in PokeTypeEffectiveness[attackerType]: PokeTypeEffectiveness[attackerType][defenderType] else: 1

proc getTypeEffectiveness*(attackerType: PokeType, defenderType: PokeType, moveName = "", isGhostRevealed = false, isFlierGrounded = false): float =
  if isGhostRevealed and defenderType == ptGhost and attackerType in {ptNormal, ptFighting}:
    return 1
  elif isFlierGrounded and defenderType == ptFlying and attackerType == ptGround:
    return 1
  elif defenderType == ptFlying and moveName == "Thousand Arrows":
    return 1
  elif defenderType == ptWater and moveName == "Freeze-Dry":
    return 2
  elif moveName == "Flying Press":
    return getTypeMatchup(ptFighting, defenderType) * getTypeMatchup(ptFlying, defenderType)
  else:
    return getTypeMatchup(attackerType, defenderType)

proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon): float =
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, attacker.ability == "Scrappy") *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, attacker.ability == "Scrappy")

proc hasType*(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc getWeightFactor*(pokemon: Pokemon): float =
  if pokemon.ability == "Heavy Metal": 2f
  elif pokemon.ability == "Light Metal": 0.5
  else: 1f

proc hasTypeChangingAbility*(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]

proc typeChangeMove*(move: PokeMove, attacker: Pokemon) =
  if move.pokeType == ptNormal:
    if attacker.ability == "Aerilate":
      move.pokeType = ptFlying
      move.modifiers.incl(pmmAerilated)
    elif attacker.ability == "Pixilate":
      move.pokeType = ptFairy
      move.modifiers.incl(pmmPixilated)
    elif attacker.ability == "Refrigerate":
      move.pokeType = ptIce
      move.modifiers.incl(pmmRefrigerated)
    elif attacker.ability == "Galvanize":
      move.pokeType = ptElectric
      move.modifiers.incl(pmmGalvanized)
    elif attacker.ability == "Liquid Voice" and pmmSound in move.modifiers:
      move.pokeType = ptWater
  elif attacker.ability == "Normalize":
    move.pokeType = ptNormal

proc skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move.name == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Dream Eater" and
    not (peAsleep in defender.state.effects) and
    defender.ability != "Comatose"
