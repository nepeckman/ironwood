import math, algorithm
import pokemon, field, poketype, pokemove, condition, item, ability

proc burnApplies(move: PokeMove, attacker: Pokemon): bool =
  sckBurned == attacker.status and move.category == pmcPhysical and
    attacker.ability != "Guts" and not (pmmIgnoresBurn in move.modifiers)

proc skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200)

proc synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move.name == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

proc dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move.name == "Dream Eater" and
    not (sckAsleep == defender.status) and
    defender.ability != "Comatose"

proc moveFails*(move: PokeMove, defender, attacker: Pokemon): bool =
  skyDropFails(move, defender) or synchronoiseFails(move, defender, attacker) or
    dreamEaterFails(move, defender)

proc isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item.kind == ikAirBalloon)

proc getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon, field: Field): float =
  let isGhostRevealed = attacker.ability == "Scrappy" or gckRevealed in defender.conditions
  let isFlierGrounded = field.gravityActive or gckGrounded in defender.conditions
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move.name, isGhostRevealed, isFlierGrounded) *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move.name, isGhostRevealed, isFlierGrounded)

proc checkAbilitySuppression(defender, attacker: Pokemon, move: PokeMove): bool =
  defender.ability notin ["Full Metal Body", "Prism Armor", "Shadow Shield"] and
    (attacker.ability in ["Mold Breaker", "Teravolt", "Turboblaze"] or move.name in ["Menacing Moonraze Maelstrom", "Moongeist Beam", "Photon Geyser", "Searing Sunraze Smash", "Sunsteel Strike"])

proc defenderProtected(defender: Pokemon, move: PokeMove): bool =
  (gckProtected in defender.conditions and not (pmmBypassesProtect in move.modifiers)) or
    (gckWideGuarded in defender.conditions and pmmSpread in move.modifiers) or
    (gckQuickGuarded in defender.conditions and not (pmmBypassesProtect in move.modifiers) and move.priority > 0)

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

proc boostedKnockOff(defender: Pokemon): bool =
  defender.hasItem() and
    not (defender.name == "Giratina-Origin" and defender.item.name == "Griseous Orb") and
    not (defender.name == "Arceus" and defender.item.kind == ikPlate) and
    not (defender.name == "Genesect" and defender.item.kind == ikDrive) and
    not (defender.ability == "RKS System" and defender.item.kind == ikMemory) and
    not (defender.item.kind in {ikZCrystal, ikMegaStone})

proc attackerAbilityBasePowerMod(attacker: Pokemon, move: PokeMove, defender: Pokemon, field: Field, typeEffectiveness: float): int =
  if (attacker.ability == "Technician" and move.basePower <= 60) or
    (attacker.ability == "Flare Boost" and attacker.status == sckBurned and move.category == pmcSpecial) or
    (attacker.ability == "Toxic Boost" and attacker.status in {sckPoisoned, sckBadlyPoisoned} and move.category == pmcPhysical): 0x1800
  elif attacker.ability == "Analytic" and defender.hasAttacked: 0x14CD
  elif attacker.ability == "Sand Force" and field.weather == fwkSand and move.pokeType in {ptRock, ptGround, ptSteel}: 0x14CD
  elif (attacker.ability == "Reckless" and pmmRecoil in move.modifiers) or
    (attacker.ability == "Iron Fist" and pmmPunch in move.modifiers): 0x1333
  elif attacker.ability == "Sheer Force" and pmmSecondaryEffect in move.modifiers: 0x14CD
  elif pmmAerilated in move.modifiers or pmmPixilated in move.modifiers or
    pmmRefrigerated in move.modifiers or pmmGalvanized in move.modifiers: 0x1200
  elif attacker.ability == "Strong Jaw" and pmmJaw in move.modifiers or
    attacker.ability == "Mega Launcher" and pmmPulse in move.modifiers: 0x1400
  elif attacker.ability == "Tough Claws" and pmmMakesContact in move.modifiers: 0x14CD
  elif attacker.ability == "Neuroforce" and typeEffectiveness > 1: 0x1400
  elif attacker.ability == "Rivalry" and pgkGenderless notin {attacker.gender, defender.gender}:
    if attacker.gender == defender.gender: 0x1400 else: 0xCCD
  else: 0x1000

proc defenderAbilityBasePowerMod(defender: Pokemon, move: PokeMove, attacker: Pokemon): int =
  if (defender.ability == "Heatproof" and move.pokeType == ptFire): 0x800
  elif (defender.ability == "Dry Skin" and move.pokeType == ptFire): 0x1400
  elif (defender.ability == "Fluffy" and
    not (pmmMakesContact in move.modifiers and attacker.ability != "Long Reach") and move.pokeType == ptFire): 0x2000
  elif (defender.ability == "Fluffy" and
    pmmMakesContact in move.modifiers and attacker.ability != "Long Reach" and move.pokeType != ptFire): 0x800
  else: 0x1000

proc attackerItemBasePowerMod(attacker: Pokemon, move: PokeMove): int =
  if attacker.item.kind in {ikPlate, ikTypeBoost}: 0x1333
  elif (attacker.item.kind == ikMuscleBand and move.category == pmcPhysical) or
    (attacker.item.kind == ikWiseGlasses and move.category == pmcSpecial): 0x1199
  elif attacker.item.kind == ikPokemonExclusive:
    if (attacker.item.name == "Adamant Orb" and attacker.name == "Dialga") or
      (attacker.item.name == "Lustrous Orb" and attacker.name == "Palkia") or
      (attacker.item.name == "Soul Dew" and attacker.name in ["Latios", "Latias", "Latios-Mega", "Latias-Mega"]) or
      (attacker.item.name == "Griseous Orb" and attacker.name == "Giratina-Origin") and attacker.hasType(move.pokeType):
      0x1333 
    else: 0x1000
  else: 0x1000

proc moveBasePowerMod(move: PokeMove, attacker, defender: Pokemon, field: Field): int =
  if (move.name == "Facade" and attacker.status != sckHealthy) or
    (move.name == "Brine" and defender.currentHP <= toInt(defender.maxHP / 2)) or
    (move.name == "Venoshock" and defender.status in {sckPoisoned, sckBadlyPoisoned}): 0x2000
  elif (move.name == "Solar Beam" and field.weather in {fwkRain, fwkHeavyRain, fwkSand, fwkHail}): 0x800
  elif (move.name == "Knock Off" and boostedKnockOff(defender)): 0x1800
  else: 0x1000

proc helpingHandMod(attacker: Pokemon): int = 
  if gckHandedHelp in attacker.conditions: 0x1800 else: 0x1000

proc auraMod(attacker, defender: Pokemon, isDefenderAbilitySuppressed: bool): int =
    if attacker.ability == "Aura Break" or
      (not isDefenderAbilitySuppressed and defender.ability == "Aura Break"): 0x0C00
    else: 0x1547


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

  if defenderProtected(defender, move):
    return noDamage

  let isDefenderAbilitySuppressed = checkAbilitySuppression(defender, attacker, move)

  if move.name == "Weather Ball": move.changeTypeWithWeather(field.weather)
  if move.isItemDependant() : move.changeTypeWithItem(attacker.item)
  if move.name == "Nature Power": move.changeTypeWithTerrain(field.terrain)
  if move.name == "Revelation Dance": move.pokeType = attacker.pokeType1
  if attacker.hasTypeChangingAbility(): move.changeTypeWithAbility(attacker.ability)

  var typeEffectiveness = getMoveEffectiveness(move, defender, attacker, field)

  if typeEffectiveness == 0:
    return noDamage

  if moveFails(move, defender, attacker): return noDamage

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
  
  ### BASE POWER
  move.basePower = if move.variablePower: calculateBasePower(move, attacker, defender) else: move.basePower
  var isSTAB = attacker.hasType(move.pokeType)
  var bpMods: seq[int] = @[]

  bpMods.add(attacker.attackerAbilityBasePowerMod(move, defender, field, typeEffectiveness))
  if not isDefenderAbilitySuppressed: bpMods.add(defender.defenderAbilityBasePowerMod(move, attacker))
  bpMods.add(attacker.attackerItemBasePowerMod(move))
  bpMods.add(move.moveBasePowerMod(attacker, defender, field))
  bpMods.add(helpingHandMod(attacker))
  if move.isAuraBoosted(field): bpMods.add(auraMod(attacker, defender, isDefenderAbilitySuppressed))

  var basePower = max(1, pokeRound(move.basePower * chainMods(bpMods) / 0x1000))

  ### (SP)ATTACK
  var attack: int
  var attackSource = if move.name == "Foul Play": defender else: attacker

  if (pmmUsesHighestAtkStat in move.modifiers):
    move.category = if attackSource.attack >= attackSource.spattack: pmcPhysical else: pmcSpecial

  attack = if move.category == pmcPhysical: attackSource.attack else: attackSource.spattack
  if not isDefenderAbilitySuppressed and defender.ability == "Unaware":
    attack =
      if move.category == pmcPhysical: attackSource.rawStats.atk else: attackSource.rawStats.spa

  if attacker.ability == "Hustle" and move.category == pmcPhysical:
    attack = pokeRound(attack * 3 / 2)

  var atkMods: seq[int] = @[]
  if not isDefenderAbilitySuppressed:
    if (defender.ability == "Thick Fat" and move.pokeType in {ptFire, ptIce}) or
      (defender.ability == "Water Bubble" and move.pokeType == ptFire):
      atkMods.add(0x800)

  if (attacker.ability == "Guts" and attacker.status != sckHealthy) or
    attacker.currentHP <= toInt(attacker.maxHP / 3) and
    (attacker.ability == "Overgrow" and move.pokeType == ptGrass or
    attacker.ability == "Blaze" and move.pokeType == ptFire or
    attacker.ability == "Torrent" and move.pokeType == ptWater or
    attacker.ability == "Swarm" and move.pokeType == ptBug):
    atkMods.add(0x1800)
  elif (gckFireFlashed in attacker.conditions) and move.pokeType == ptFire:
    atkMods.add(0x1800)
  elif field.weather in {fwkSun, fwkHarshSun} and 
    (attacker.ability == "Solar Power" and move.category == pmcSpecial or
    attacker.ability == "Flower Gift" and move.category == pmcPhysical):
    atkMods.add(0x1800)
  elif (attacker.ability == "Defeatist" and attacker.currentHP <= toInt(attacker.maxHP / 2)) or
    (attacker.ability == "Slow Start" and move.category == pmcPhysical):
    atkMods.add(0x800)
  elif attacker.ability in ["Huge Power", "Pure Power"] and move.category == pmcPhysical:
    atkMods.add(0x2000)

  if
    (attacker.item.name == "Thick Club" and attacker.name in ["Cubone", "Marowak", "Marowak-Alola"] and
    move.category == pmcPhysical) or
    (attacker.item.name == "Deep Sea Tooth" and attacker.name == "Clamperl" and
    move.category == pmcSpecial) or
    (attacker.item.name == "Light Ball" and attacker.name == "Pikachu"):
    atkMods.add(0x2000)
  elif (attacker.item.name == "Choice Band" and move.category == pmcPhysical) or
    (attacker.item.name == "Choice Specs" and move.category == pmcSpecial):
    atkMods.add(0x1800)

  attack = max(1, pokeRound(attack * chainMods(atkMods) / 0x1000))

  ### (SP)DEFENSE
  var defense =
    if move.category == pmcPhysical or pmmDealsPhysicalDamage in move.modifiers: defender.defense
    else: defender.spdefense

  var baseDamage = getBaseDamage(attacker.level, basePower, attack, defense)

  var stabMod = 0x1000
  if isSTAB:
    stabMod = if attacker.ability == "Adaptability": 0x2000 else: 0x1800

  let applyBurn = burnApplies(move, attacker)

  result = noDamage
  for i in 0..15:
    result[i] = getFinalDamage(baseDamage, i, typeEffectiveness, applyBurn, stabMod, 0x1000)




var snorlaxStats: PokeStats = (hp: 244, atk: 178, def: 109, spa: 85, spd: 130, spe: 45)
var attacker = makePokemon("Snorlax", ptNormal, stats = snorlaxStats)
var defender = makePokemon("Snorlax", ptNormal, stats = snorlaxStats)
var move = PokeMove(
    name: "Return",
    category: pmcPhysical,
    basePower: 102,
    variablePower: false,
    pokeType: ptNormal,
    priority: 0,
    modifiers: {}
    )

let damage = getDamageResult(attacker, defender, move, makeField())
echo damage
