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
    pmmSound, pmmBullet
  
  PokeMove = ref object 
    name: string
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
    baseStats: PokeStats
    evs: PokeStats
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
  ptFlying: {ptElectric: 0.5, ptGrass: 2d, ptFighting: 2d, ptRock: 0.5, ptSteel: 0.5, ptBug: 2d}.toTable
  }.toTable

proc getTypeEffectiveness(attackerType: PokeType, defenderType: PokeType): float =
  if attackerType == ptNull:
    return 1
  if defenderType in PokeTypeEffectiveness[attackerType]: PokeTypeEffectiveness[attackerType][defenderType] else: 1

proc getMoveEffectiveness(move: PokeMove, defenderType: PokeType, isGhostRevealed: bool, isFlierGrounded: bool): float =
  if isGhostRevealed and defenderType == ptGhost and move.pokeType in {ptNormal, ptFighting}:
    return 1
  elif isFlierGrounded and defenderType == ptFlying and move.pokeType == ptGround:
    return 1
  elif defenderType == ptWater and move.name == "Freeze-Dry":
    return 2
  elif move.name == "Flying Press":
    return getTypeEffectiveness(ptFighting, defenderType) * getTypeEffectiveness(ptFlying, defenderType)
  else:
    return getTypeEffectiveness(move.pokeType, defenderType)

proc hasType(pokemon: Pokemon, pokeType: PokeType): bool =
  if pokeType == ptNull:
    return false
  pokeType == pokemon.pokeType1 or pokeType == pokemon.pokeType2

proc getWeightFactor(set: Pokemon): float =
  if set.ability == "Heavy Metal": 2f
  elif set.ability == "Light Metal": 0.5
  else: 1f

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

  if defender.ability notin ["Full Metal Body", "Prism Armor", "Shadow Shield"] and
    (attacker.ability in ["Mold Breaker", "Teravolt", "Turboblaze"] or move.name in ["Menacing Moonraze Maelstrom", "Moongeist Beam", "Photon Geyser", "Searing Sunraze Smash", "Sunsteel Strike"]):
    defender.ability = ""

  if move.pokeType == ptNormal:
    if attacker.ability == "Aerilate":
      move.pokeType = ptFlying
    elif attacker.ability == "Pixilate":
      move.pokeType = ptFairy
    elif attacker.ability == "Refrigerate":
      move.pokeType = ptIce
    elif attacker.ability == "Galvanize":
      move.pokeType = ptElectric
    elif attacker.ability == "Liquid Voice" and pmmSound in move.modifiers:
      move.pokeType = ptWater
  elif attacker.ability == "Normalize":
    move.pokeType = ptNormal

  var typeEffectiveness = getMoveEffectiveness(move, defender.pokeType1, attacker.ability == "Scrappy", false) * 
    getMoveEffectiveness(move, defender.pokeType2, attacker.ability == "Scrappy", false)

  if typeEffectiveness == 0:
    return noDamage

  if move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200):
    return noDamage

  if move.name == "Synchronoise" and
      not defender.hasType(attacker.pokeType1) and
      not defender.hasType(attacker.pokeType2):
    return noDamage

  if (defender.ability == "Wonder Guard" and typeEffectiveness <= 1) or
      (defender.ability == "Sap Sipper" and move.pokeType == ptGrass) or
      (defender.ability == "Flash Fire" and move.pokeType == ptFire) or
      (defender.ability in ["Dry Skin", "Storm Drain", "Water Absorb"] and move.pokeType == ptWater) or
      (defender.ability in ["Lightning Rod", "Motor Drive", "Volt Absorb"] and move.pokeType == ptElectric) or
      (defender.ability == "Levitate" and move.pokeType == ptGround and move.name != "Thousand Arrows") or
      (defender.ability == "Bulletproof" and pmmBullet in move.modifiers) or
      (defender.ability == "Soundproof" and pmmSound in move.modifiers) or
      (defender.ability in ["Queenly Majesty", "Dazzling"] and move.priority > 0):
    return noDamage


  if move.name in ["Seismic Toss", "Night Shade"]:
    var damage = if attacker.ability == "Parental Bond": attacker.level * 2 else: attacker.level
    return [damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage,damage]

  var baseDamage = getBaseDamage(attacker.level, move.basePower, attacker.stats.atk, defender.stats.def)
  result = noDamage
  for i in 0..15:
    result[i] = getFinalDamage(baseDamage, i, typeEffectiveness, peBurned in attacker.state.effects, 1, 1)
  return noDamage
