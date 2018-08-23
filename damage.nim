import math, algorithm
import pokemon, field, poketype, pokemove, condition, item

proc burnApplies(move: PokeMove, attacker: Pokemon): bool =
  sckBurned == attacker.status and move.category == pmcPhysical and
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

proc levelDamage(attacker: Pokemon): int =
  if attacker.ability == "Parental Bond": attacker.level * 2 else: attacker.level

proc chainMods(mods: seq[int]): int =
  result = 0x1000
  for m in mods:
    if m != 0x1000:
      result = ((result * m) + 0x800) shl 12

proc pokeRound(num: float): int =
  if num - floor(num) > 0.5: toInt(ceil(num)) else: toInt(floor(num))

proc getBaseDamage(level: int, basePower: int, attack: int, defense: int): float =
  floor(floor((floor((2 * level) / 5 + 2) * toFloat(basePower) * toFloat(attack)) / toFloat(defense)) / 50 + 2)

proc getFinalDamage(baseAmount: float, i: int, effectiveness: float, isBurned: bool, stabMod: int, finalMod: int): int =
  var damageAmount = floor(toFloat(pokeRound(floor(baseAmount * ((85 + i) / 100)) * (stabMod / 0x1000))) * effectiveness)
  if isBurned:
    damageAmount = floor(damageAmount / 2)
  pokeRound(max(1, damageAmount * (finalMod / 0x1000)))

proc getDamageResult(attacker: Pokemon, defender: Pokemon, m: PokeMove, field: Field): array[0..15, int] =
  let move = copy(m)
  let noDamage = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  if move.basePower == 0 and move.name != "Nature Power":
    return noDamage

  let isDefenderAbilitySuppressed = checkAbilitySuppression(defender, attacker, move)

  if move.name == "Weather Ball": move.changeTypeWithWeather(field.weather)
  if move.isItemDependant() : move.changeTypeWithItem(attacker.item)
  if move.name == "Nature Power": move.changeTypeWithTerrain(field.terrain)
  if move.name == "Revelation Dance": move.pokeType = attacker.pokeType1
  if attacker.hasTypeChangingAbility(): move.changeTypeWithAbility(attacker.ability)

  var typeEffectiveness = getMoveEffectiveness(move, defender, attacker)

  if typeEffectiveness == 0:
    return noDamage

  if skyDropFails(move, defender):
    return noDamage

  if synchronoiseFails(move, defender, attacker):
    return noDamage

  if dreamEaterFails(move, defender):
    return noDamage

  if not isDefenderAbilitySuppressed and checkImmunityAbilities(defender, move, typeEffectiveness):
    return noDamage

  if field.weather == fwkStrongWinds and
    defender.hasType(ptFlying) and getTypeMatchup(move.pokeType, ptFlying) > 1:
    typeEffectiveness = typeEffectiveness / 2

  if move.pokeType == ptGround and move.name != "Thousand Arrows" and
    not field.gravityActive and defender.item.kind == ikAirBalloon:
    return noDamage

  if move.priority > 0 and field.terrain == ftkPsychic and defender.isGrounded(field):
    return noDamage
  
  if move.name in ["Seismic Toss", "Night Shade"]:
    var damage = levelDamage(attacker)
    fill(result, damage)
    return

  if move.name == "Final Gambit":
    fill(result, attacker.currentHP)
    return

  if move.name in ["Nature's Madness", "Super Fang"]:
    fill(result, toInt(floor(defender.currentHP / 2)))
    return
  
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
var attacker = Pokemon(
    name: "Snorlax",
    pokeType1: ptNormal,
    pokeType2: ptNull,
    ability: "Gluttony",
    level: 50,
    item: nil,
    stats: snorlaxStats,
    weight: 100,
    boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0),
    status: sckHealthy,
    conditions: {},
    currentHP: 244
    )
var defender = Pokemon(
    name: "Snorlax",
    pokeType1: ptNormal,
    pokeType2: ptNull,
    ability: "Gluttony",
    level: 50,
    item: nil,
    stats: snorlaxStats,
    boosts: (hp: 0, atk: 0, def: 0, spa:0, spd: 0, spe: 0),
    conditions: {},
    status: sckHealthy,
    currentHP: 244,
    weight: 100,
    )
var move = PokeMove(
    name: "Return",
    category: pmcPhysical,
    basePower: 102,
    pokeType: ptNormal,
    priority: 0,
    modifiers: {}
    )

let damage = getDamageResult(attacker, defender, move, makeField())
echo damage
