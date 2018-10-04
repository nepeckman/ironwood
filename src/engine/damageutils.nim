import 
  math,
  gameData/gameData,
  gameObjects/gameObjects

func burnApplies*(move: PokeMove, attacker: Pokemon): bool =
  sckBurned == attacker.status and move.category == pmcPhysical and
    attacker.ability != "Guts" and not (pmmIgnoresBurn in move.modifiers)

func skyDropFails*(move: PokeMove, defender: Pokemon): bool =
  move == "Sky Drop" and (defender.hasType(ptFlying) or defender.weight >= 200f)

func synchronoiseFails*(move: PokeMove, defender: Pokemon, attacker: Pokemon): bool =
  move == "Synchronoise" and
    not defender.hasType(attacker.pokeType1) and
    not defender.hasType(attacker.pokeType2)

func dreamEaterFails*(move: PokeMove, defender: Pokemon): bool =
  move == "Dream Eater" and
    not (sckAsleep == defender.status) and
    defender.ability != "Comatose"

func moveFails*(move: PokeMove, defender, attacker: Pokemon): bool =
  skyDropFails(move, defender) or synchronoiseFails(move, defender, attacker) or
    dreamEaterFails(move, defender)

func isGrounded*(pokemon: Pokemon, field: Field): bool =
  field.gravityActive or
    not (pokemon.hasType(ptFlying) or pokemon.ability == "Levitate" or pokemon.item == "Air Balloon")

func getTypeEffectiveness*(attackerType: PokeType, defenderType: PokeType, move: PokeMove,
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

func getMoveEffectiveness*(move: PokeMove, defender, attacker: Pokemon, field: Field): float =
  let isGhostRevealed = attacker.ability == "Scrappy" or gckRevealed in defender.conditions
  let isFlierGrounded = field.gravityActive or gckGrounded in defender.conditions
  getTypeEffectiveness(move.pokeType, defender.pokeType1, move, isGhostRevealed, isFlierGrounded) *
    getTypeEffectiveness(move.pokeType, defender.pokeType2, move, isGhostRevealed, isFlierGrounded)

func isDefenderAbilitySuppressed*(defender, attacker: Pokemon, move: PokeMove): bool =
  defender.ability notin ["Full Metal Body", "Prism Armor", "Shadow Shield"] and
    (attacker.ability in ["Mold Breaker", "Teravolt", "Turboblaze"] or move in ["Menacing Moonraze Maelstrom", "Moongeist Beam", "Photon Geyser", "Searing Sunraze Smash", "Sunsteel Strike"])

func defenderProtected*(defender: Pokemon, move: PokeMove): bool =
  (gckProtected in defender.conditions and not (pmmBypassesProtect in move.modifiers)) or
    (gckWideGuarded in defender.conditions and pmmSpread in move.modifiers) or
    (gckQuickGuarded in defender.conditions and not (pmmBypassesProtect in move.modifiers) and move.priority > 0)

func hasImmunityViaAbility*(defender: Pokemon, move: PokeMove, typeEffectiveness: float): bool =
  (defender.ability == "Wonder Guard" and typeEffectiveness <= 1) or
    (defender.ability == "Sap Sipper" and move.pokeType == ptGrass) or
    (defender.ability == "Flash Fire" and move.pokeType == ptFire) or
    (defender.ability in ["Dry Skin", "Storm Drain", "Water Absorb"] and move.pokeType == ptWater) or
    (defender.ability in ["Lightning Rod", "Motor Drive", "Volt Absorb"] and move.pokeType == ptElectric) or
    (defender.ability == "Levitate" and move.pokeType == ptGround and move != "Thousand Arrows") or
    (defender.ability == "Bulletproof" and pmmBullet in move.modifiers) or
    (defender.ability == "Soundproof" and pmmSound in move.modifiers) or
    (defender.ability in ["Queenly Majesty", "Dazzling"] and move.priority > 0)

func changeTypeWithAbility(move: PokeMove, ability: Ability) =
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

func changeTypeWithItem(move: PokeMove, item: Item) =
  if item.kind in {ikDrive, ikPlate, ikMemory}:
    move.pokeType = item.associatedType

func naturePowerTransformation(move: PokeMove, terrain: FieldTerrainKind) =
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

func weatherBallTransformation(move: PokeMove, weather: FieldWeatherKind) =
  move.pokeType = case weather
    of fwkSun, fwkHarshSun: ptFire
    of fwkRain, fwkHeavyRain: ptWater
    of fwkSand: ptRock
    of fwkHail: ptIce
    else: ptNormal
  move.basePower = if weather == fwkNone or weather == fwkStrongWinds: 50 else: 100

func speedRatioToBasePower(speedRatio: float): int =
  if speedRatio >= 4: 150
  elif speedRatio >= 3: 120
  elif speedRatio >= 2: 80
  else: 60

func weightToBasePower(weight: float): int =
  if weight >= 200f: 120
  elif weight >= 100f: 100
  elif weight >= 50f: 80
  elif weight >= 25f: 60
  elif weight >= 10f: 40
  else: 20

func weightRatioToBasePower(weightRatio: float): int =
  if weightRatio >= 5: 120
  elif weightRatio >= 4: 100
  elif weightRatio >= 3: 80
  elif weightRatio >= 2: 60
  else: 40

func healthRatioToBasePower(healthRatio: float): int =
  if healthRatio <= 1: 200
  elif healthRatio <= 4: 150
  elif healthRatio <= 9: 100
  elif healthRatio <= 16: 80
  elif healthRatio <= 32: 40
  else: 20

func variableBasePower(move: PokeMove, attacker: Pokemon, defender: Pokemon, field: Field): int =
  case move.name
  of "Payback":
    if gckHasAttacked in defender.conditions: 100 else: 50
  of "Electro Ball": speedRatioToBasePower(floor(attacker.speed(field) / defender.speed(field)))
  of "Gyro Ball": min(150, 1 + toInt(floor(25 * defender.speed(field) / attacker.speed(field))))
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

func isItemDependant(move: PokeMove): bool =
  move.name in ["Judgement", "Techno Blast", "Multi-Attack", "Natural Gift"]

func damageStepMoveTransformation*(move: PokeMove, attacker, defender: Pokemon, field: Field): PokeMove =
  result = copy(move)
  #TODO: return new moves by querying the movedex
  if move == "Weather Ball": result.weatherBallTransformation(field.weather)
  if move.isItemDependant() : result.changeTypeWithItem(attacker.item)
  if move == "Nature Power": result.naturePowerTransformation(field.terrain)
  if move == "Revelation Dance": result.pokeType = attacker.pokeType1
  if attacker.hasTypeChangingAbility(): result.changeTypeWithAbility(attacker.ability)
  result.basePower = if pmmVariablePower in move.modifiers: variableBasePower(move, attacker, defender, field) else: move.basePower

func isAuraBoosted*(move: PokeMove, field: Field): bool =
  (fakDark in field.auras and move.pokeType == ptDark) or
    (fakFairy in field.auras and move.pokeType == ptFairy)

func boostedKnockOff*(defender: Pokemon): bool =
  defender.hasItem() and
    not (defender.name == "Giratina-Origin" and defender.item == "Griseous Orb") and
    not (defender.name == "Arceus" and defender.item.kind == ikPlate) and
    not (defender.name == "Genesect" and defender.item.kind == ikDrive) and
    not (defender.ability == "RKS System" and defender.item.kind == ikMemory) and
    not (defender.item.kind in {ikZCrystal, ikMegaStone})
