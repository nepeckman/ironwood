import 
  math, algorithm, sets,
  gameData/gameData,
  gameObjects/gameObjects,
  damageutils

type
  DamageSpread* = array[0..15, int]
  DamageInternalState = tuple[isSTAB, defAbilitySuppressed: bool, typeEffectiveness: float]

proc chainMods(mods: seq[int]): int =
  result = 0x1000
  for m in mods:
    if m != 0x1000:
      result = ((result * m) + 0x800) shl 12

proc pokeRound(num: float): int =
  if num - floor(num) > 0.5: toInt(ceil(num)) else: toInt(floor(num))

proc attackerAbilityBasePowerMod(attacker: Pokemon, move: PokeMove, defender: Pokemon, field: Field, typeEffectiveness: float): int =
  if (attacker.ability == "Technician" and move.basePower <= 60) or
    (attacker.ability == "Flare Boost" and attacker.status == sckBurned and move.category == pmcSpecial) or
    (attacker.ability == "Toxic Boost" and attacker.status in {sckPoisoned, sckBadlyPoisoned} and move.category == pmcPhysical): 0x1800
  elif attacker.ability == "Analytic" and gckHasAttacked in defender.conditions: 0x14CD
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
    if (attacker.item == "Adamant Orb" and attacker.name == "Dialga") or
      (attacker.item == "Lustrous Orb" and attacker.name == "Palkia") or
      (attacker.item == "Soul Dew" and attacker.name in ["Latios", "Latias", "Latios-Mega", "Latias-Mega"]) or
      (attacker.item == "Griseous Orb" and attacker.name == "Giratina-Origin") and attacker.hasType(move.pokeType):
      0x1333 
    else: 0x1000
  else: 0x1000

proc moveBasePowerMod(move: PokeMove, attacker, defender: Pokemon, field: Field): int =
  if (move == "Facade" and attacker.status != sckHealthy) or
    (move == "Brine" and defender.currentHP <= toInt(defender.maxHP / 2)) or
    (move == "Venoshock" and defender.status in {sckPoisoned, sckBadlyPoisoned}): 0x2000
  elif (move == "Solar Beam" and field.weather in {fwkRain, fwkHeavyRain, fwkSand, fwkHail}): 0x800
  elif (move == "Knock Off" and boostedKnockOff(defender)): 0x1800
  else: 0x1000

proc auraMod(attacker, defender: Pokemon, defAbilitySuppressed: bool): int =
    if attacker.ability == "Aura Break" or
      (not defAbilitySuppressed and defender.ability == "Aura Break"): 0x0C00
    else: 0x1547

proc helpingHandMod(attacker: Pokemon): int = 
  if gckHandedHelp in attacker.conditions: 0x1800 else: 0x1000

proc calculateBasePower(move: PokeMove, attacker, defender: Pokemon, field: Field,
  typeEffectiveness: float, defAbilitySuppressed: bool): int =
  var bpMods: seq[int] = @[]
  bpMods.add(attacker.attackerAbilityBasePowerMod(move, defender, field, typeEffectiveness))
  if not defAbilitySuppressed: bpMods.add(defender.defenderAbilityBasePowerMod(move, attacker))
  bpMods.add(attacker.attackerItemBasePowerMod(move))
  bpMods.add(move.moveBasePowerMod(attacker, defender, field))
  bpMods.add(helpingHandMod(attacker))
  if move.isAuraBoosted(field): bpMods.add(auraMod(attacker, defender, defAbilitySuppressed))
  max(1, pokeRound(move.basePower * chainMods(bpMods) / 0x1000))

proc attackerAbilityAttackMod(attacker: Pokemon, move: PokeMove, field: Field): int =
  if (attacker.ability == "Guts" and attacker.status != sckHealthy) or
    attacker.currentHP <= toInt(attacker.maxHP / 3) and
    (attacker.ability == "Overgrow" and move.pokeType == ptGrass or
    attacker.ability == "Blaze" and move.pokeType == ptFire or
    attacker.ability == "Torrent" and move.pokeType == ptWater or
    attacker.ability == "Swarm" and move.pokeType == ptBug): 0x1800
  elif (gckFireFlashed in attacker.conditions) and move.pokeType == ptFire: 0x1800
  elif field.weather in {fwkSun, fwkHarshSun} and 
    (attacker.ability == "Solar Power" and move.category == pmcSpecial or
    attacker.ability == "Flower Gift" and move.category == pmcPhysical): 0x1800
  elif (attacker.ability == "Defeatist" and attacker.currentHP <= toInt(attacker.maxHP / 2)) or
    (attacker.ability == "Slow Start" and move.category == pmcPhysical): 0x800
  elif attacker.ability in ["Huge Power", "Pure Power"] and move.category == pmcPhysical: 0x2000
  else: 0x1000

proc defenderAbilityAttackMod(defender: Pokemon, move: PokeMove): int =
    if (defender.ability == "Thick Fat" and move.pokeType in {ptFire, ptIce}) or
      (defender.ability == "Water Bubble" and move.pokeType == ptFire): 0x800
    else: 0x1000

proc attackerItemAttackMod(attacker: Pokemon, move: PokeMove): int =
  if
    (attacker.item == "Thick Club" and attacker.name in ["Cubone", "Marowak", "Marowak-Alola"] and
    move.category == pmcPhysical) or
    (attacker.item == "Deep Sea Tooth" and attacker.name == "Clamperl" and
    move.category == pmcSpecial) or
    (attacker.item == "Light Ball" and attacker.name == "Pikachu"): 0x2000
  elif (attacker.item == "Choice Band" and move.category == pmcPhysical) or
    (attacker.item == "Choice Specs" and move.category == pmcSpecial): 0x1800
  else: 0x1000

proc calculateAttack(attacker: Pokemon, move: PokeMove, defender: Pokemon, field: Field, defAbilitySuppressed: bool): int =
  var attack: int
  var attackSource = if move == "Foul Play": defender else: attacker

  if (pmmUsesHighestAtkStat in move.modifiers):
    move.category = if attackSource.attack >= attackSource.spattack: pmcPhysical else: pmcSpecial
    #TODO: move this to move transformation

  attack = if move.category == pmcPhysical: attackSource.attack else: attackSource.spattack
  if not defAbilitySuppressed and defender.ability == "Unaware":
    attack =
      if move.category == pmcPhysical: attackSource.rawStats.atk else: attackSource.rawStats.spa

  if attacker.ability == "Hustle" and move.category == pmcPhysical:
    attack = pokeRound(attack * 3 / 2)

  var atkMods: seq[int] = @[]
  atkMods.add(attacker.attackerAbilityAttackMod(move, field))
  if not defAbilitySuppressed: atkMods.add(defender.defenderAbilityAttackMod(move))
  atkMods.add(attacker.attackerItemAttackMod(move))
  max(1, pokeRound(attack * chainMods(atkMods) / 0x1000))

proc defenderAbilityDefenseMod(defender: Pokemon, field: Field, hitsPhysical: bool): int = 
    if defender.ability == "Marvel Scale" and defender.status != sckHealthy and hitsPhysical: 0x1800
    elif defender.ability == "Flower Gift" and field.weather in {fwkSun, fwkHarshSun} and not hitsPhysical: 0x1800
    elif defender.ability == "Grass Pelt" and field.terrain == ftkGrass: 0x1800
    elif defender.ability == "Fur Coat" and hitsPhysical: 0x2000
    else: 0x1000

proc defenderItemDefenseMod(defender: Pokemon, hitsPhysical: bool): int =
  if (defender.item == "Metal Powder" and defender.name == "Ditto" and hitsPhysical) or
    (defender.item == "Deep Sea Scale" and defender.name == "Clamperl" and not hitsPhysical): 0x2000
  elif (defender.item == "Eviolite" and pdfHasEvolution in defender.dataFlags) or
    (not hitsPhysical and defender.item == "Assault Vest"): 0x1800
  else: 0x1000

proc calculateDefense(defender, attacker: Pokemon, move: PokeMove, field: Field, defAbilitySuppressed: bool): int =
  let hitsPhysical = move.category == pmcPhysical or pmmDealsPhysicalDamage in move.modifiers
  var defense = 
    if pmmIgnoresDefenseBoosts in move.modifiers or attacker.ability == "Unaware":
      if  hitsPhysical: defender.rawStats.def else: defender.rawStats.spd
    else:
      if hitsPhysical: defender.defense else: defender.spdefense
  if field.weather == fwkSand and defender.hasType(ptRock) and not hitsPhysical:
    defense = pokeRound(defense * 3 / 2)
  var defMods: seq[int] = @[]
  if not defAbilitySuppressed: defMods.add(defender.defenderAbilityDefenseMod(field, hitsPhysical))
  defMods.add(defender.defenderItemDefenseMod(hitsPhysical))
  max(1, pokeRound(defense * chainMods(defMods) / 0x1000))

proc attackerAbilityFinalMod(attacker: Pokemon, move: PokeMove, typeEffectiveness: float): int =
  if (attacker.ability == "Tinted Lens" and typeEffectiveness < 1) or
    (attacker.ability == "Water Bubble" and move.pokeType == ptWater): 0x2000
  elif attacker.ability == "Steelworker" and move.pokeType == ptSteel: 0x1800
  else: 0x1000

proc defenderAbilityFinalMod(defender: Pokemon, typeEffectiveness: float): int =
    if defender.ability in ["Multiscale", "Shadow Shield"] and defender.currentHP == defender.maxHP: 0x800
    elif defender.ability in ["Solid Rock", "Filter", "Prism Armor"] and typeEffectiveness > 1: 0xC00
    else: 0x1000

proc attackerItemFinalMod(attacker: Pokemon, typeEffectiveness: float): int = 
  if attacker.item == "Expert Belt" and typeEffectiveness > 1: 0x1333
  elif attacker.item == "Life Orb": 0x14CC
  else: 0x1000

proc defenderItemFinalMod(defender, attacker: Pokemon, move: PokeMove): int =
  if defender.item.kind == ikResistBerry and
    move.pokeType == defender.item.associatedType and
    attacker.ability != "Unnerve": 0x800
  else: 0x1000

proc doesNoDamage(move: PokeMove, attacker, defender: Pokemon, field: Field,
  typeEffectiveness: float, defAbilitySuppressed: bool): bool =
  move.basePower == 0 or typeEffectiveness == 0 or
    defenderProtected(defender, move) or moveFails(move, defender, attacker) or
    (not defAbilitySuppressed and hasImmunityViaAbility(defender, move, typeEffectiveness)) or
    (move.priority > 0 and field.terrain == ftkPsychic and defender.isGrounded(field)) or
    (defender.item.kind == ikAirBalloon and move.pokeType == ptGround and
    move != "Thousand Arrows" and not field.gravityActive) or
    (field.weather == fwkHarshSun and move.pokeType == ptWater) or
    (field.weather == fwkHeavyRain and move.pokeType == ptFire)

proc levelDamage(attacker: Pokemon): int =
  if attacker.ability == "Parental Bond": attacker.level * 2 else: attacker.level

proc calculateConsistentDamage(move: PokeMove, attacker, defender: Pokemon): DamageSpread =
  var damage = 0
  if move in ["Seismic Toss", "Night Shade"]:
    damage = levelDamage(attacker)
  if move == "Final Gambit":
    damage = attacker.currentHP
  if move in ["Nature's Madness", "Super Fang"]:
    damage = toInt(floor(defender.currentHP / 2))
  fill(result, damage)

proc getBaseDamage(level: int, basePower: int, attack: int, defense: int): int =
  toInt(floor(floor((floor((2 * level) / 5 + 2) * toFloat(basePower) * toFloat(attack)) / toFloat(defense)) / 50 + 2))

proc calculateBaseDamage(attacker, defender: Pokemon, move: PokeMove, field: Field, basePower, attack, defense: int): int =
  var baseDamage = getBaseDamage(attacker.level, basePower, attack, defense)

  if field.format != ffkSingles and pmmSpread in move.modifiers:
    baseDamage = pokeRound(baseDamage  * 0xC00 / 0x1000)

  if (field.weather in {fwkSun, fwkHarshSun} and move.pokeType == ptFire) or
    (field.weather in {fwkRain, fwkHeavyRain} and move.pokeType == ptWater):
    baseDamage = pokeRound(baseDamage * 0x1800 / 0x1000)
  elif (field.weather == fwkSun and move.pokeType == ptWater) or
    (field.weather == fwkRain and move.pokeType == ptFire):
    baseDamage = pokeRound(baseDamage * 0x800 / 0x1000)
  
  if isGrounded(attacker, field):
    if (field.terrain == ftkGrass and move.pokeType == ptGrass) or
      (field.terrain == ftkPsychic and move.pokeType == ptPsychic) or
      (field.terrain == ftkElectric and move.pokeType == ptElectric):
      baseDamage = pokeRound(baseDamage * 0x1800 / 0x1000)
    elif (field.terrain == ftkFairy and move.pokeType == ptDragon) or
      (field.terrain == ftkGrass and move in ["Bulldoze", "Earthquake"]):
      baseDamage = pokeRound(baseDamage * 0x800 / 0x1000)
  return baseDamage

proc calculateFinalMod(attacker, defender: Pokemon, move: PokeMove, field: Field,
  typeEffectiveness: float, defAbilitySuppressed: bool): int =
  var finalMods: seq[int] = @[]
  let defenderSideEffects = field.sideEffects(defender.side)
  if (fseAuroraVeil in defenderSideEffects) or
    (fseLightScreen in defenderSideEffects and move.category == pmcSpecial) or
    (fseReflect in defenderSideEffects and move.category == pmcPhysical):
    finalMods.add(if field.format == ffkSingles: 0xAAC else: 0x800)

  finalMods.add(attacker.attackerAbilityFinalMod(move, typeEffectiveness))
  if not defAbilitySuppressed: finalMods.add(defender.defenderAbilityFinalMod(typeEffectiveness))
  finalMods.add(attacker.attackerItemFinalMod(typeEffectiveness))
  finalMods.add(defender.defenderItemFinalMod(attacker, move))

  if gckFriendGuarded in defender.conditions:
    finalMods.add(0xC00)
  chainMods(finalMods)

proc getFinalDamage(baseAmount: int, i: int, effectiveness: float, isBurned: bool, stabMod: int, finalMod: int): int =
  var damageAmount = floor(toFloat(pokeRound(floor(toFloat(baseAmount) * ((85 + i) / 100)) * (stabMod / 0x1000))) * effectiveness)
  if isBurned:
    damageAmount = floor(damageAmount / 2)
  pokeRound(max(1, damageAmount * (finalMod / 0x1000)))

proc getDamageSpread*(attacker: Pokemon, defender: Pokemon, m: PokeMove, field: Field): DamageSpread =
  let noDamage = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  let move = m.damageStepMoveTransformation(attacker, defender, field)

  var isSTAB = attacker.hasType(move.pokeType)
  let defAbilitySuppressed = isDefenderAbilitySuppressed(defender, attacker, move)
  var typeEffectiveness = getMoveEffectiveness(move, defender, attacker, field)

  if field.weather == fwkStrongWinds and
    defender.hasType(ptFlying) and getTypeMatchup(move.pokeType, ptFlying) > 1:
    typeEffectiveness = typeEffectiveness / 2

  if move.doesNoDamage(attacker, defender, field, typeEffectiveness, defAbilitySuppressed):
    return noDamage

  if pmmConsistentDamage in move.modifiers:
    return move.calculateConsistentDamage(attacker, defender)

  var basePower = 
    move.calculateBasePower(attacker, defender, field, typeEffectiveness, defAbilitySuppressed)
  var attack = attacker.calculateAttack(move, defender, field, defAbilitySuppressed)
  var defense = defender.calculateDefense(attacker, move, field, defAbilitySuppressed)

  var baseDamage =
    calculateBaseDamage(attacker, defender, move, field, basePower, attack, defense)

  let finalMod = calculateFinalMod(attacker, defender, move, field, typeEffectiveness, defAbilitySuppressed)

  var stabMod =
    if isSTAB:
      if attacker.ability == "Adaptability": 0x2000 else: 0x1800
    else: 0x1000

  let applyBurn = burnApplies(move, attacker)

  result = noDamage
  for i in 0..15:
    result[i] = getFinalDamage(baseDamage, i, typeEffectiveness, applyBurn, stabMod, finalMod)

proc getAvgDamage*(attacker: Pokemon, defender: Pokemon, move: PokeMove, field: Field): int =
  let spread = getDamageSpread(attacker, defender, move, field)
  toInt(sum(spread) / spread.len)
