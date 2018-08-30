import math
import pokemon, pokemove, poketype, item, ability, condition, field

proc burnApplies*(move: PokeMove, attacker: Pokemon): bool =
  sckBurned == attacker.status and move.category == pmcPhysical and
    attacker.ability != "Guts" and not (pmmIgnoresBurn in move.modifiers)

proc skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move == "Dream Eater" and
    not (sckAsleep == defender.status) and
    defender.ability != "Comatose"

proc moveFails*(move: PokeMove, defender, attacker: Pokemon): bool =
  skyDropFails(move, defender) or synchronoiseFails(move, defender, attacker) or
    dreamEaterFails(move, defender)

proc isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item.kind == ikAirBalloon)

proc getTypeEffectiveness*(attackerType: PokeType, defenderType: PokeType, move: PokeMove,
  isGhostRevealed = false, isFlierGrounded = false): float =
  if isGhostRevealed and defenderType == ptGhost and attackerType in {ptNormal, ptFighting}:
    return 1
  elif isFlierGrounded and defenderType == ptFlying and attackerType == ptGround:
    return 1
  elif defenderType == ptFlying and move == "Thousand Arrows":
    return 1
  elif defenderType == ptWater and move == "Freeze-Dry":
    return 2
  elif move == "Flying Press":
    return getTypeMatchup(ptFighting, defenderType) * getTypeMatchup(ptFlying, defenderType)
  else:
    return getTypeMatchup(attackerType, defenderType)

proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon, field: Field): float =
  let isGhostRevealed = attacker.ability == "Scrappy" or gckRevealed in defender.conditions
  let isFlierGrounded = field.gravityActive or gckGrounded in defender.conditions
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move, isGhostRevealed, isFlierGrounded) *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move, isGhostRevealed, isFlierGrounded)

proc isDefenderAbilitySuppressed*(defender, attacker: Pokemon, move: PokeMove): bool =
  defender.ability notin ["Full Metal Body", "Prism Armor", "Shadow Shield"] and
    (attacker.ability in ["Mold Breaker", "Teravolt", "Turboblaze"] or move in ["Menacing Moonraze Maelstrom", "Moongeist Beam", "Photon Geyser", "Searing Sunraze Smash", "Sunsteel Strike"])

proc defenderProtected*(defender: Pokemon, move: PokeMove): bool =
  (gckProtected in defender.conditions and not (pmmBypassesProtect in move.modifiers)) or
    (gckWideGuarded in defender.conditions and pmmSpread in move.modifiers) or
    (gckQuickGuarded in defender.conditions and not (pmmBypassesProtect in move.modifiers) and move.priority > 0)

proc hasImmunityViaAbility*(defender: Pokemon, move: PokeMove, typeEffectiveness: float): bool =
  (defender.ability == "Wonder Guard" and typeEffectiveness <= 1) or
    (defender.ability == "Sap Sipper" and move.pokeType == ptGrass) or
    (defender.ability == "Flash Fire" and move.pokeType == ptFire) or
    (defender.ability in ["Dry Skin", "Storm Drain", "Water Absorb"] and move.pokeType == ptWater) or
    (defender.ability in ["Lightning Rod", "Motor Drive", "Volt Absorb"] and move.pokeType == ptElectric) or
    (defender.ability == "Levitate" and move.pokeType == ptGround and move != "Thousand Arrows") or
    (defender.ability == "Bulletproof" and pmmBullet in move.modifiers) or
    (defender.ability == "Soundproof" and pmmSound in move.modifiers) or
    (defender.ability in ["Queenly Majesty", "Dazzling"] and move.priority > 0)

proc calculateBasePower*(move: PokeMove, attacker: Pokemon, defender: Pokemon): int =
  case move.name
  of "Payback":
    if defender.hasAttacked: 100 else: 50
  of "Electro Ball": speedRatioToBasePower(floor(attacker.speed / defender.speed))
  of "Gyro Ball": min(150, 1 + toInt(floor(25 * defender.speed / attacker.speed)))
  of "Punishment": min(200, 60 + 20 * countBoosts(defender))
  of "Low Kick", "Grass Knot": weightToBasePower(defender.weight)
  of "Hex":
    if defender.status == sckHealthy: move.basePower else: move.basePower * 2
  of "Heavy Slam", "Heat Crash": weightRatioToBasePower(attacker.weight / defender.weight)
  of "Stored Power", "Power Trip": 20 + 20 * attacker.countBoosts()
  of "Acrobatics":
    if attacker.item == nil: 110 else: 55
  of "Wake-Up Slap":
    if defender.status == sckHealthy: move.basePower * 2 else: move.basePower
  of "Fling": getFlingPower(attacker.item)
  of "Eruption", "Water Spout": max(1, toInt(floor(150 * attacker.currentHP / attacker.maxHP)))
  of "Flail", "Reversal": healthRatioToBasePower(floor(48 * attacker.currentHP / attacker.maxHP))
  of "Wring Out": 1 + toInt(120 * defender.currentHP / defender.maxHP)
  else: move.basePower

proc boostedKnockOff*(defender: Pokemon): bool =
  defender.hasItem() and
    not (defender.name == "Giratina-Origin" and defender.item == "Griseous Orb") and
    not (defender.name == "Arceus" and defender.item.kind == ikPlate) and
    not (defender.name == "Genesect" and defender.item.kind == ikDrive) and
    not (defender.ability == "RKS System" and defender.item.kind == ikMemory) and
    not (defender.item.kind in {ikZCrystal, ikMegaStone})
