import math, tables

type
  PokeType = enum
    ptWater, ptFire, ptElectric, ptDark, ptPsychic, ptGrass, ptIce, ptDragon, ptFairy,
    ptNormal, ptFighting, ptRock, ptGround, ptSteel, ptGhost, ptPoison, ptBug, ptFlying,
    ptNull

  PokeStats = tuple[hp: int, atk: int, def: int, spa: int, spd: int, spe: int]

  PokeEffect = enum
    peSleep, peConfused, pePoisoned, peBurned, peParalyzed

  PokeNature = enum
    pnModest, pnTimid, pnAdamant, pnJolly, pnBold, pnCalm, pnCareful, pnImpish, pnBrave, pnRelaxed, pnQuiet, pnSassy

  PokeState = ref object
    boosts: PokeStats
    effects: set[PokeEffect]
    currentHP: int

  PokeMoveModifiers = enum
    pmmSound, pmmBullet, pmmAerilated, pmmPixilated, pmmRefrigerated, pmmGalvanized, pmmUsesHighestAtkStat,
    pmmDealsPhysicalDamage, pmmIgnoresBurn
  
  PokeMoveCategory = enum
    pmcPhysical, pmcSpecial, pmcStatus

  PokeMove = ref object 
    name: string
    category: PokeMoveCategory
    basePower: int
    pokeType: PokeType
    priority: int
    modifiers: set[PokeMoveModifiers]

  Pokemon = ref object
    name: string
    pokeType1: PokeType
    pokeType2: PokeType
    ability: string
    level: int
    item: string
    nature: PokeNature
    stats: PokeStats
    weight: float
    state: PokeState


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

proc getTypeMatchup(attackerType, defenderType: PokeType): float =
  if defenderType in PokeTypeEffectiveness[attackerType]: PokeTypeEffectiveness[attackerType][defenderType] else: 1

proc getTypeEffectiveness(attackerType: PokeType, defenderType: PokeType, moveName = "", isGhostRevealed = false, isFlierGrounded = false): float =
  if isGhostRevealed and defenderType == ptGhost and attackerType in {ptNormal, ptFighting}:
    return 1
  elif isFlierGrounded and defenderType == ptFlying and attackerType == ptGround:
    return 1
  elif defenderType == ptWater and moveName == "Freeze-Dry":
    return 2
  elif moveName == "Flying Press":
    return getTypeMatchup(ptFighting, defenderType) * getTypeMatchup(ptFlying, defenderType)
  else:
    return getTypeMatchup(attackerType, defenderType)

proc getMoveEffectiveness(move: PokeMove, defender, attacker: Pokemon): float =
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, attacker.ability == "Scrappy") *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, attacker.ability == "Scrappy")

proc hasType(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc getWeightFactor(set: Pokemon): float =
  if set.ability == "Heavy Metal": 2f
  elif set.ability == "Light Metal": 0.5
  else: 1f

proc burnApplies(move: PokeMove, attacker: Pokemon): bool =
  peBurned in attacker.state.effects and move.category == pmcPhysical and
    attacker.ability != "Guts" and not (pmmIgnoresBurn in move.modifiers)

proc checkAbilitySuppression(defender, attacker: Pokemon, move: PokeMove): bool =
  defender.ability notin ["Full Metal Body", "Prism Armor", "Shadow Shield"] and
    (attacker.ability in ["Mold Breaker", "Teravolt", "Turboblaze"] or move.name in ["Menacing Moonraze Maelstrom", "Moongeist Beam", "Photon Geyser", "Searing Sunraze Smash", "Sunsteel Strike"])

proc checkImmunityAbilities(defender: Pokemon, move: PokeMove, typeEffectiveness: float): bool =
  (defender.ability == "Wonder Guard" and typeEffectiveness <= 1) or
    (defender.ability == "Sap Sipper" and move.pokeType == ptGrass) or
    (defender.ability == "Flash Fire" and move.pokeType == ptFire) or
    (defender.ability in ["Dry Skin", "Storm Drain", "Water Absorb"] and move.pokeType == ptWater) or
    (defender.ability in ["Lightning Rod", "Motor Drive", "Volt Absorb"] and move.pokeType == ptElectric) or
    (defender.ability == "Levitate" and move.pokeType == ptGround and move.name != "Thousand Arrows") or
    (defender.ability == "Bulletproof" and pmmBullet in move.modifiers) or
    (defender.ability == "Soundproof" and pmmSound in move.modifiers) or
    (defender.ability in ["Queenly Majesty", "Dazzling"] and move.priority > 0)

proc hasTypeChangingAbility(pokemon: Pokemon): bool =
  pokemon.ability in ["Aerliate", "Pixilate", "Refrigerate", "Galvanize", "Liquid Voice", "Normalize"]

proc typeChangeMove(move: PokeMove, attacker: Pokemon) =
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


proc skyDropFails(move: PokeMove, defender: Pokemon): bool =
  move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move.name == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc levelDamage(attacker: Pokemon): int =
  if attacker.ability == "Parental Bond": attacker.level * 2 else: attacker.level

proc pokeRound(num: float): int =
  if num - floor(num) > 0.5: toInt(ceil(num)) else: toInt(floor(num))

proc getBaseDamage(level: int, basePower: int, attack: int, defense: int): float =
  floor(floor((floor((2 * level) / 5 + 2) * toFloat(basePower) * toFloat(attack)) / toFloat(defense)) / 50 + 2)

proc chainMods(mods: seq[int]): int =
  result = 0x1000
  for m in mods:
    if m != 0x1000:
      result = ((result * m) + 0x800) shl 12

proc getFinalDamage(baseAmount: float, i: int, effectiveness: float, isBurned: bool, stabMod: int, finalMod: int): int =
  var damageAmount = floor(toFloat(pokeRound(floor(baseAmount * ((85 + i) / 100)) * (stabMod / 0x1000))) * effectiveness)
  if isBurned:
    damageAmount = floor(damageAmount / 2)
  pokeRound(max(1, damageAmount * (finalMod / 0x1000)))

proc getDamageResult(attacker: Pokemon, defender: Pokemon, move: PokeMove): array[0..15, int] =
  let noDamage = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  if move.basePower == 0:
    return noDamage

  let isDefenderAbilitySuppressed = checkAbilitySuppression(defender, attacker, move)

  if attacker.hasTypeChangingAbility(): move.typeChangeMove(attacker)

  var typeEffectiveness = getMoveEffectiveness(move, defender, attacker)

  if typeEffectiveness == 0:
    return noDamage

  if skyDropFails(move, defender):
    return noDamage

  if synchronoiseFails(move, defender, attacker):
    return noDamage

  if not isDefenderAbilitySuppressed and checkImmunityAbilities(defender, move, typeEffectiveness):
    return noDamage
  
  if move.name in ["Seismic Toss", "Night Shade"]:
    var damage = levelDamage(attacker)
    return [damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage]

  
  var basePower = move.basePower
  var isSTAB = attacker.hasType(move.pokeType)

  var attack: int
  var attackSource = if move.name == "Foul Play": defender else: attacker

  if (pmmUsesHighestAtkStat in move.modifiers):
    move.category = if attackSource.stats.atk >= attackSource.stats.spa: pmcPhysical else: pmcSpecial

  attack = if move.category == pmcPhysical: attackSource.stats.atk else: attackSource.stats.spa

  var defense = if move.category == pmcPhysical or pmmDealsPhysicalDamage in move.modifiers: defender.stats.def
    else: defender.stats.spd

  var baseDamage = getBaseDamage(attacker.level, basePower, attack, defense)

  var stabMod = 0x1000
  if isSTAB:
    stabMod = if attacker.ability == "Adaptability": 0x2000 else: 0x1800

  let applyBurn = burnApplies(move, attacker)

  result = noDamage
  for i in 0..15:
    result[i] = getFinalDamage(baseDamage, i, typeEffectiveness, applyBurn, stabMod, 0x1000)

var snorlaxStats: PokeStats = (hp: 244, atk: 178, def: 109, spa: 85, spd: 130, spe: 45)
var neutralState = PokeState(boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0), effects: {}, currentHP: 244)
var attacker = Pokemon(
    name: "Snorlax",
    pokeType1: ptNormal,
    pokeType2: ptNull,
    ability: "Gluttony",
    level: 50,
    item: "",
    nature: pnBrave,
    stats: snorlaxStats,
    weight: 100,
    state: neutralState
    )
var defender = Pokemon(
    name: "Snorlax",
    pokeType1: ptNormal,
    pokeType2: ptNull,
    ability: "Gluttony",
    level: 50,
    item: "",
    nature: pnBrave,
    stats: snorlaxStats,
    weight: 100,
    state: neutralState
    )
var move = PokeMove(
    name: "Return",
    category: pmcPhysical,
    basePower: 102,
    pokeType: ptNormal,
    priority: 0,
    modifiers: {}
    )

let damage = getDamageResult(attacker, defender, move)
echo damage
