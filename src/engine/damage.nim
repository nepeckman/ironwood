import math, algorithm, sets
import state, team, pokemon, field, poketype, pokemove, condition, item, ability, engineutils

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

proc defenderAbilityDefenseMod(defender: Pokemon, field: Field, hitsPhysical: bool): int = 
    if defender.ability == "Marvel Scale" and defender.status != sckHealthy and hitsPhysical: 0x1800
    elif defender.ability == "Flower Gift" and field.weather in {fwkSun, fwkHarshSun} and not hitsPhysical: 0x1800
    elif defender.ability == "Grass Pelt" and field.terrain == ftkGrass: 0x1800
    elif defender.ability == "Fur Coat" and hitsPhysical: 0x2000
    else: 0x1000

proc defenderItemDefenseMod(defender: Pokemon, hitsPhysical: bool): int =
  if (defender.item == "Metal Powder" and defender.name == "Ditto" and hitsPhysical) or
    (defender.item == "Deep Sea Scale" and defender.name == "Clamperl" and not hitsPhysical): 0x2000
  elif (defender.item == "Eviolite" and defender.hasEvolution) or
    (not hitsPhysical and defender.item == "Assault Vest"): 0x1800
  else: 0x1000

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
    move.pokeType == defender.item.resistedType and
    attacker.ability != "Unnerve": 0x800
  else: 0x1000

proc helpingHandMod(attacker: Pokemon): int = 
  if gckHandedHelp in attacker.conditions: 0x1800 else: 0x1000

proc auraMod(attacker, defender: Pokemon, defAbilitySuppressed: bool): int =
    if attacker.ability == "Aura Break" or
      (not defAbilitySuppressed and defender.ability == "Aura Break"): 0x0C00
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

proc getBaseDamage(level: int, basePower: int, attack: int, defense: int): int =
  toInt(floor(floor((floor((2 * level) / 5 + 2) * toFloat(basePower) * toFloat(attack)) / toFloat(defense)) / 50 + 2))

proc getFinalDamage(baseAmount: int, i: int, effectiveness: float, isBurned: bool, stabMod: int, finalMod: int): int =
  var damageAmount = floor(toFloat(pokeRound(floor(toFloat(baseAmount) * ((85 + i) / 100)) * (stabMod / 0x1000))) * effectiveness)
  if isBurned:
    damageAmount = floor(damageAmount / 2)
  pokeRound(max(1, damageAmount * (finalMod / 0x1000)))

proc getDamageResult(attacker: Pokemon, defender: Pokemon, m: PokeMove, state: State): array[0..15, int] =
  let move = copy(m)
  let field = state.field
  let noDamage = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  if move.basePower == 0 and move != "Nature Power":
    return noDamage

  if defenderProtected(defender, move):
    return noDamage

  let defAbilitySuppressed = isDefenderAbilitySuppressed(defender, attacker, move)

  if move == "Weather Ball": move.weatherBallTransformation(field.weather)
  if move.isItemDependant() : move.changeTypeWithItem(attacker.item)
  if move == "Nature Power": move.naturePowerTransformation(field.terrain)
  if move == "Revelation Dance": move.pokeType = attacker.pokeType1
  if attacker.hasTypeChangingAbility(): move.changeTypeWithAbility(attacker.ability)

  var typeEffectiveness = getMoveEffectiveness(move, defender, attacker, field)

  if typeEffectiveness == 0:
    return noDamage

  if moveFails(move, defender, attacker): return noDamage

  if not defAbilitySuppressed and hasImmunityViaAbility(defender, move, typeEffectiveness):
    return noDamage

  if field.weather == fwkStrongWinds and
    defender.hasType(ptFlying) and getTypeMatchup(move.pokeType, ptFlying) > 1:
    typeEffectiveness = typeEffectiveness / 2

  if move.pokeType == ptGround and move != "Thousand Arrows" and
    not field.gravityActive and defender.item.kind == ikAirBalloon:
    return noDamage

  if move.priority > 0 and field.terrain == ftkPsychic and defender.isGrounded(field):
    return noDamage
  
  if move in ["Seismic Toss", "Night Shade"]:
    var damage = levelDamage(attacker)
    fill(result, damage)
    return

  if move == "Final Gambit":
    fill(result, attacker.currentHP)
    return

  if move in ["Nature's Madness", "Super Fang"]:
    fill(result, toInt(floor(defender.currentHP / 2)))
    return
  
  ### BASE POWER
  move.basePower = if move.variablePower: calculateBasePower(move, attacker, defender) else: move.basePower
  var isSTAB = attacker.hasType(move.pokeType)
  var bpMods: seq[int] = @[]

  bpMods.add(attacker.attackerAbilityBasePowerMod(move, defender, field, typeEffectiveness))
  if not defAbilitySuppressed: bpMods.add(defender.defenderAbilityBasePowerMod(move, attacker))
  bpMods.add(attacker.attackerItemBasePowerMod(move))
  bpMods.add(move.moveBasePowerMod(attacker, defender, field))
  bpMods.add(helpingHandMod(attacker))
  if move.isAuraBoosted(field): bpMods.add(auraMod(attacker, defender, defAbilitySuppressed))

  var basePower = max(1, pokeRound(move.basePower * chainMods(bpMods) / 0x1000))

  ### (SP)ATTACK
  var attack: int
  var attackSource = if move == "Foul Play": defender else: attacker

  if (pmmUsesHighestAtkStat in move.modifiers):
    move.category = if attackSource.attack >= attackSource.spattack: pmcPhysical else: pmcSpecial

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

  attack = max(1, pokeRound(attack * chainMods(atkMods) / 0x1000))

  ### (SP)DEFENSE
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
  
  defense = max(1, pokeRound(defense * chainMods(defMods) / 0x1000))

  ### DAMAGE
  var baseDamage = getBaseDamage(attacker.level, basePower, attack, defense)

  if field.format != ffkSingles and pmmSpread in move.modifiers:
    baseDamage = pokeRound(baseDamage  * 0xC00 / 0x1000)

  if (field.weather in {fwkSun, fwkHarshSun} and move.pokeType == ptFire) or
    (field.weather in {fwkRain, fwkHeavyRain} and move.pokeType == ptWater):
    baseDamage = pokeRound(baseDamage * 0x1800 / 0x1000)
  elif (field.weather == fwkSun and move.pokeType == ptWater) or
    (field.weather == fwkRain and move.pokeType == ptFire):
    baseDamage = pokeRound(baseDamage * 0x800 / 0x1000)
  elif (field.weather == fwkHarshSun and move.pokeType == ptWater) or
    (field.weather == fwkHeavyRain and move.pokeType == ptFire):
    return noDamage
  
  if isGrounded(attacker, field):
    if (field.terrain == ftkGrass and move.pokeType == ptGrass) or
      (field.terrain == ftkPsychic and move.pokeType == ptPsychic) or
      (field.terrain == ftkElectric and move.pokeType == ptElectric):
      baseDamage = pokeRound(baseDamage * 0x1800 / 0x1000)

  if isGrounded(defender, field):
    if field.terrain == ftkFairy and move.pokeType == ptDragon:
      baseDamage = pokeRound(baseDamage * 0x800 / 0x1000)
    elif field.terrain == ftkGrass and move in ["Bulldoze", "Earthquake"]:
      baseDamage = pokeRound(baseDamage * 0x800 / 0x1000)

  var stabMod = 0x1000
  if isSTAB:
    stabMod = if attacker.ability == "Adaptability": 0x2000 else: 0x1800

  let applyBurn = burnApplies(move, attacker)

  var finalMods: seq[int] = @[]
  let defenderSideEffects = field.sideEffects(state.getTeam(defender))
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

  let finalMod = chainMods(finalMods)

  result = noDamage
  for i in 0..15:
    result[i] = getFinalDamage(baseDamage, i, typeEffectiveness, applyBurn, stabMod, finalMod)


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
var homeTeam = makeTeam([attacker, attacker, attacker, attacker, attacker, attacker], tskHome)
var awayTeam = makeTeam([defender, defender, defender, defender, defender, defender], tskAway)
var gameState = State(homeTeam: homeTeam, awayTeam: awayTeam, field: makeField())

let damage = getDamageResult(attacker, defender, move, gameState)
echo damage
